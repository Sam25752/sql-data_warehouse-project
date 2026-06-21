--create stored procedure
create or alter procedure bronze.load_bronze as
begin
	declare @start_time datetime, @end_time datetime, @batch_start_time datetime, @batch_end_time datetime;
	begin try
	set @batch_start_time= getdate();
		print '=====================================';
		print 'Loading the bronze layer';
		print '=====================================';
		--inserting data from csv files
		--full load
		print '--------------------------------------';
		print 'Loading CRM Tables';
		print '--------------------------------------';

		set @start_time= getdate();
		truncate table bronze.crm_cust_info;
		print '>> Inserting into crm_cust_info';
		bulk insert bronze.crm_cust_info
		from 'C:\Users\DELL\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		with (
			firstrow = 2,
			fieldterminator= ',',
			tablock
		);
		set @end_time= getdate();
		print 'Load Duration: ' + cast(datediff(second, @start_time,@end_time) as nvarchar) + 'seconds';
		print '---------------------------------------';


		set @start_time= getdate();
		truncate table bronze.crm_prd_info;
		print '>> Inserting into crm_prd_info';
		bulk insert bronze.crm_prd_info
		from 'C:\Users\DELL\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		with (
			firstrow = 2,
			fieldterminator= ',',
			tablock
		);
		set @end_time= getdate();
		print 'Load Duration: ' + cast(datediff(second, @start_time,@end_time) as nvarchar) + 'seconds';
		print '---------------------------------------';


		set @start_time= getdate();
		truncate table bronze.crm_sales_details;
		print '>> Inserting into crm_sales_details';
		bulk insert bronze.crm_sales_details
		from 'C:\Users\DELL\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		with (
			firstrow = 2,
			fieldterminator= ',',
			tablock
		);
		set @end_time= getdate();
		print 'Load Duration: ' + cast(datediff(second, @start_time,@end_time) as nvarchar) + 'seconds';
		print '---------------------------------------';



		print '--------------------------------------------';
		print 'Loading ERP Tables';
		print '--------------------------------------------';


		set @start_time= getdate();
		truncate table [bronze].[erp_px_cat_g1v2];
		print '>> Inserting into [erp_px_cat_g1v2]';
		bulk insert [bronze].[erp_px_cat_g1v2]
		from 'C:\Users\DELL\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		with (
			firstrow = 2,
			fieldterminator= ',',
			tablock
		);
		set @end_time= getdate();
		print 'Load Duration: ' + cast(datediff(second, @start_time,@end_time) as nvarchar) + 'seconds';
		print '---------------------------------------';


		set @start_time= getdate();
		truncate table [bronze].[erp_cust_az12];
		print '>> Inserting into [erp_cust_az12]';
		bulk insert [bronze].[erp_cust_az12]
		from 'C:\Users\DELL\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		with (
			firstrow = 2,
			fieldterminator= ',',
			tablock
		);
		set @end_time= getdate();
		print 'Load Duration: ' + cast(datediff(second, @start_time,@end_time) as nvarchar) + 'seconds';
		print '---------------------------------------';


		set @start_time= getdate();
		truncate table [bronze].[erp_loc_a101];
		print '>> Inserting into [erp_loc_a101]';
		bulk insert [bronze].[erp_loc_a101]
		from 'C:\Users\DELL\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv'
		with (
			firstrow = 2,
			fieldterminator= ',',
			tablock
		);
		set @end_time= getdate();
		print 'Load Duration: ' + cast(datediff(second, @start_time,@end_time) as nvarchar) + 'seconds';
		print '---------------------------------------';

		set @batch_end_time= getdate();
		print '======================================='
		print 'Loading Bronze layer is completed'
		print 'Total Load Duration: ' + cast(datediff(second, @batch_start_time,@batch_end_time) as nvarchar) + 'seconds';
		print '======================================='

	end try
	begin catch
		print '==============================================';
		print 'error occured during loading bronze layer';
		print 'Error Message' + error_message();
		print 'Error Number' + cast(error_number() as nvarchar);
		print '==============================================';
	end catch
end
