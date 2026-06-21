use master;
go

--drop and recreate 'DataWarehouse' database
if exists (select 1 from sys.databases where name='DataWarehouse')
begin
	alter database DataWarehouse set single_user with rollback immediate;
	drop database DataWarehouse;
end;
go


--creating database 'DataWarehouse'
create database DataWarehouse;

use DataWarehouse;
go

--create schemas
create schema bronze;
go
create schema silver;
go
create schema gold;
go
