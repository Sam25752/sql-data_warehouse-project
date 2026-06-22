--creating stored procedure

create or alter procedure silver.load_silver as
begin
	print '=====================================';
	print 'Loading the silver layer';
	print '=====================================';


	print '--------------------------------------';
	print 'Loading CRM Tables';
	print '--------------------------------------';
	print '--------------------';
	--data cleansing and loading into silver.crm_cust_info
	print '>>Truncating table silver.crm_cust_info'
	truncate table silver.crm_cust_info;
	print '>>Inserting data into silver.crm_cust_info';
	insert into silver.crm_cust_info (
		cst_id,
		cst_key,
		cst_firstname,
		cst_lastname,
		cst_marital_status,
		cst_gndr,
		cst_create_date)
	select 
		cst_id,
		cst_key,
		trim(cst_firstname) as cst_firstname,
		trim(cst_lastname) as cst_lastname, --remove unwanted spaces
		case when upper(trim(cst_marital_status)) = 'M' then 'Married'
			when upper(trim(cst_marital_status)) = 'S' then 'Single'
			else 'n\a'
		end as cst_marital_status, --normalise marital status values to readable format
		case when upper(trim(cst_gndr)) = 'M' then 'Male'
			when upper(trim(cst_gndr)) = 'F' then 'Female'
			else 'n\a' --handling nulls
		end as cst_gndr, --normalise gender values to readable format
		cst_create_date
	from (
		select 
		*,
		row_number() over(partition by cst_id order by cst_create_date desc) as flag_last --remove duplicates
		from bronze.crm_cust_info
		where cst_id is not null --removing nulls
	)t
	where flag_last = 1
	print '--------------------';



	--data cleansing and loading into silver.crm_prd_info
	print '--------------------';
	print '>>Truncating table silver.crm_prd_info'
	truncate table silver.crm_prd_info;
	print '>>Inserting data into silver.crm_prd_info';
	insert into silver.crm_prd_info (
	prd_id,
	cat_id,
	prd_key,
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt)

	select 
	prd_id,
	replace(substring(prd_key, 1, 5), '-', '_') as cat_id, --extract category id
	substring(prd_key, 7, len(prd_key)) as prd_key, --extract product id
	prd_nm,
	isnull(prd_cost, 0) as prd_cost,
	case upper(trim(prd_line))
		when 'M' then 'Mountain'
		when 'R' then 'Road'
		when 'S' then 'Other Sales'
		when 'T' then 'Touring'
		else 'n\a'
	end as prd_line, --map product line codes to descriptive values
	cast(prd_start_dt as date) as prd_start_dt,
	cast(
		lead(prd_start_dt) over (partition by prd_key order by prd_start_dt asc)-1 
		as DATE
		) as prd_end_dt --calculate end date as one day before next start date
	from bronze.crm_prd_info
	print '--------------------';



	--data cleansing and loading into silver.crm_sales_details
	print '--------------------';
	print '>>Truncating table silver.crm_sales_details'
	truncate table silver.crm_sales_details;
	print '>>Inserting data into silver.crm_sales_details';
	insert into silver.crm_sales_details (
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		sls_order_dt,
		sls_ship_dt,
		sls_due_dt,
		sls_sales,
		sls_quantity,
		sls_price
	)
	select
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		case when sls_order_dt=0 or len(sls_order_dt)!=8 then null
			else cast(cast(sls_order_dt as varchar) as date) --cannot cast directly int to date
		end sls_order_dt, --correcting invalid dates
		case when sls_ship_dt=0 or len(sls_ship_dt)!=8 then null
			else cast(cast(sls_ship_dt as varchar) as date) --cannot cast directly int to date
		end sls_ship_dt,
		case when sls_due_dt=0 or len(sls_due_dt)!=8 then null
			else cast(cast(sls_due_dt as varchar) as date) --cannot cast directly int to date
		end sls_due_dt,
		case when sls_sales is null or sls_sales <= 0 or sls_sales != sls_quantity * abs(sls_price)
			then sls_quantity * abs(sls_price)
		else sls_sales
	end as sls_Sales, --recalculating sales if original value is missing or incorrect
		sls_quantity,
		case when sls_price is null or sls_price<=0
			then sls_sales/nullif(sls_quantity, 0) 
		else sls_price
	end as sls_price --derive price if original is incorrect
	from bronze.crm_sales_details
	print '--------------------';




	print '--------------------------------------------';
	print 'Loading ERP Tables';
	print '--------------------------------------------';
	--data cleansing and loading into silver.erp_cust_az12
	print '--------------------';
	print '>>Truncating table silver.erp_cust_az12'
	truncate table silver.erp_cust_az12;
	print '>>Inserting data into silver.erp_cust_az12';
	insert into silver.erp_cust_az12 (
		cid,
		bdate,
		gen
	)
	select
		case when cid like 'NAS%' THEN substring(cid, 4, len(cid))
			ELSE cid 
		end cid, --remove 'NAS' prefix if present
		case when bdate> getdate() then null
			else bdate
		end as bdate, --set future birth dates to null
		case when trim(upper(gen)) in ('M', 'MALE') then 'Male'
			when trim(upper(gen)) in ('F', 'FEMALE') then 'Female'
			else 'n\a'
		end gen --normalise gender values and handle unknown cases
	from bronze.erp_cust_az12
	print '--------------------';



	--data cleansing and loading into silver.erp_loc_a101
	print '--------------------';
	print '>>Truncating table silver.erp_loc_a101'
	truncate table silver.erp_loc_a101;
	print '>>Inserting data into silver.erp_loc_a101';
	insert into silver.erp_loc_a101(
		cid,
		cntry
	)
	select 
		replace(cid, '-', '')cid,
		case when trim(cntry) = 'DE' then 'Germany'
			when trim(cntry) in ('US', 'USA') then 'United States'
			when trim(cntry)='' or cntry is null then 'n\a'
			else cntry
		end as cntry --normalise and handle missing or blank country codes
	from bronze.erp_loc_a101
	print '--------------------';



	--data cleansing and loading into silver.erp_loc_a101
	print '--------------------';
	print '>>Truncating table silver.erp_px_cat_g1v2'
	truncate table silver.erp_px_cat_g1v2;
	print '>>Inserting data into silver.erp_px_cat_g1v2';
	insert into silver.erp_px_cat_g1v2(
	id,
	cat,
	subcat,
	maintenance
	)
	select id,
	cat,
	subcat,
	maintenance
	from bronze.erp_px_cat_g1v2
	print '--------------------';
end
