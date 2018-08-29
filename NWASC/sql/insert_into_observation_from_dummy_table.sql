/*
Upload test data from R to make sure it looks ok and to create the geometry field
*/

-- check data visually 
select * from [NWASC].[dbo].[obs_test]

-- create geometry field
alter table obs_test add geographyColumn 
as geography::STGeomFromText('POINT('+convert(varchar(20),longitude)+' '+convert(varchar(20),latitude)+')',4326)

-- add to observation table
insert into observation (observation_id,source_obs_id,dataset_id,transect_id,obs_dt,obs_tm,original_species_tx,
spp_cd,obs_count_intrans_nb,obs_count_general_nb,observer_tx,observer_position,seconds_from_midnight,
original_age_tx,age_id,plumage_tx,original_behavior_tx,behavior_id,original_sex_tx,sex_id,
travel_direction_tx,heading_tx,flight_height_tx,distance_to_animal_tx,angle_from_observer_nb,
associations_tx,visibility_tx,seastate_beaufort_nb,wind_speed_tx,wind_dir_tx,cloud_cover_tx,
wave_height_tx,camera_reel,observer_confidence,observer_comments,geographyColumn,admin_notes) 
select 
observation_id,source_obs_id,dataset_id,transect_id,obs_dt,obs_tm,original_species_tx,
spp_cd,obs_count_intrans_nb,obs_count_general_nb,observer_tx,observer_position,seconds_from_midnight,
original_age_tx,age_id,plumage_tx,original_behavior_tx,behavior_id,original_sex_tx,sex_id,
travel_direction_tx,heading_tx,flight_height_tx,distance_to_animal_tx,angle_from_observer_nb,
associations_tx,visibility_tx,seastate_beaufort_nb,wind_speed_tx,wind_dir_tx,cloud_cover_tx,
wave_height_tx,camera_reel,observer_confidence,observer_comments,geographyColumn,admin_notes
from obs_test

-- check data
select * from observation

-- drop table
drop table obs_test
