--DATA CLEANSING IN CRM_CUST_INFO

--check for nulls and duplicates in primary key
--expectation: no result 
select 
cst_id,
count(*)
from bronze.crm_cust_info
group by cst_id
having count(*) !=1 or cst_id is null

--check for unwanted spaces in string values
--expectation: no result
--here firstname and lastname need to be cleared
select 
cst_id,
cst_firstname
from bronze.crm_cust_info
where cst_firstname != trim(cst_firstname)

--data standardization and consistency
select distinct cst_gndr
from bronze.crm_cust_info;
select distinct cst_marital_status
from bronze.crm_cust_info



--DATA CLEANSING IN CRM_PRD_INFO
select *
from bronze.crm_prd_info

--check for nulls and duplicates in primary key
--expectation: no result 
select 
prd_id,
count(*)
from bronze.crm_prd_info
group by prd_id
having count(*) !=1 or prd_id is null

--prd_key has 2 information category and subcategory

--check for unwanted spaces in string values
--expectation: no result
select 
prd_nm
from bronze.crm_prd_info
where prd_nm != trim(prd_nm)

--check for nulls or negative numbers
--expectation: no result
select prd_cost
from bronze.crm_prd_info
where prd_cost <0 or prd_cost is null

--data standardization and consistency
select distinct prd_line
from bronze.crm_prd_info

--check for invalid Date Orders
--end date must not be before start date
--end date of one record in history should be before start date of next
--so that no overlapping in cost
--end date= start date of next record - 1 
select *
from bronze.crm_prd_info
where prd_end_dt < prd_start_dt



--DATA CLEANSING IN CRM_SALES_DETAILS

--check for invalid dates
--well shipping date and due date are fine but will still apply the logic for future 
select 
nullif(sls_order_dt,0) sls_order_dt
from bronze.crm_sales_details
where sls_order_dt <= 0 or len(sls_order_dt) != 8

--checking for invalid date orders
--expectation: no result
select
*
from bronze.crm_sales_details
where sls_order_dt > sls_ship_dt or sls_order_dt > sls_due_dt

--checking sales,quantity and price
--if sales is negative, zero or null, derive using price and quantity
--if price is zero or null, calculate using sales and quantity
--if price is negative, convert to positive
select *
from bronze.crm_sales_details
where sls_sales != sls_quantity * sls_price
or sls_Sales is null 
or sls_quantity is null 
or sls_price is null
or sls_Sales <=0  
or sls_quantity <=0 
or sls_price <=0 



--DATA CLEANSING IN ERP_CUST_AZ12

--remove that nas from start of cid

--identify out of range dates
select distinct bdate
from bronze.erp_cust_az12
where bdate<'1926-06-22' or bdate > getdate()

--data standardization and consistency
select distinct gen
from bronze.erp_cust_az12



--DATA CLEANSING IN erp_loc_a101

--data standardization and cleansing
select distinct cntry
from bronze.erp_loc_a101
order by cntry


--DATA CLEANSING IN erp_px_cat_g1v2
--well this table has really good data quality
--check for unwanted spaces in strings
select 
maintenance
from bronze.erp_px_cat_g1v2
where maintenance!=trim(maintenance)

--data standardization and consistency
select distinct maintenance
from bronze.erp_px_cat_g1v2


