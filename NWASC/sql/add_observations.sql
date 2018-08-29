/*
Upload test data from R to make sure it looks ok and to create the geometry field
*/

-- check data visually 
select * from [NWASC].[dbo].[obs_test]

-- create geometry field
alter table obs_test add geographyColumn 
as geography::STGeomFromText('POINT('+convert(varchar(20),longitude)+' '+convert(varchar(20),latitude)+')',4326)

-- add to observation table
insert into observation select * from obs_test
