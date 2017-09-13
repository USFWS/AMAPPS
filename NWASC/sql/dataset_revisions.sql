-- documented dataset revisions
-- outlined in the lu_revision_details table

--135_2 the date 1/11/2011 should be 1/11/2012
UPDATE observation
SET source_transect_id = '2012-01-11_NJM', obs_dt = '1/11/2012'
WHERE source_transect_id = '2011-01-11_NJM';

UPDATE track
SET source_transect_id = '2012-01-11_NJM', track_dt = '1/11/2012'
WHERE source_transect_id = '2011-01-11_NJM';

UPDATE transect
SET source_transect_id = '2012-01-11_NJM', start_dt = '1/11/2012', end_dt = '1/11/2012'
WHERE source_transect_id = '2011-01-11_NJM';

UPDATE dataset
SET version = 2
WHERE dataset_id = 135
