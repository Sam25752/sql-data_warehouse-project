--create view for customer details

if object_id('gold.dim_customers', 'V') is not null
  drow view gold.dim_customers
go
  
create view gold.dim_customers as
select 
	row_number() over(order by cst_id) as customer_key,
	ci.cst_id as customer_id,
	ci.cst_key as customer_number,
	ci.cst_firstname as firstname,
	ci.cst_lastname as lastname,
	la.cntry as country,
	ci.cst_marital_status as marital_status,
	case when ci.cst_gndr != 'n\a' then ci.cst_gndr --crm is the master for gender info
		else coalesce(ca.gen, 'n\a')
	end as gender,
	ca.bdate as birth_date,
	ci.cst_create_date as create_date
from silver.crm_cust_info as ci
left join silver.erp_cust_az12 as ca
on ci.cst_key=ca.cid
left join silver.erp_loc_a101 as la
on ci.cst_key=la.cid





--creating view for product details
  if object_id('gold.dim_products', 'V') is not null
  drow view gold.dim_products
go
  
create view gold.dim_products as 
select 
	row_number() over(order by pm.prd_start_dt, pm.prd_key) as product_key,
	pm.prd_id as product_id,
	pm.prd_key as product_number,
	pm.prd_nm as product_name,
	pm.cat_id as category_id,
	pc.cat as category,
	pc.subcat as subcategory,
	pc.maintenance,
	pm.prd_cost as cost,
	pm.prd_line as product_line,
	pm.prd_start_dt as start_date
from silver.crm_prd_info as pm
left join silver.erp_px_cat_g1v2 as pc
on pm.cat_id=pc.id
where pm.prd_end_dt is null --filter out all historical data 




--creating view for sales details (transactional details)
   if object_id('gold.fact_sales', 'V') is not null
  drow view gold.fact_sales
go
  
create view gold.fact_sales as 
SELECT
sd.sls_ord_num as order_number,
pr.product_key,
cu.customer_id,
sd.sls_order_dt as order_date,
sd.sls_ship_dt as shipping_date,
sd.sls_due_dt as due_date,
sd.sls_sales as sales_amount,
sd.sls_quantity as quantity,
sd.sls_price as price
from silver.crm_sales_details as sd
left join gold.dim_products as pr
on sd.sls_prd_key = pr.product_number
left join gold.dim_customers as cu
on sd.sls_cust_id= cu.customer_id
