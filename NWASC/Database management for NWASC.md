Database management for the Northwest Atlantic Seabird Catalog 
===

For FWS personnel: Details can be found at the FWS NWASC [website](https://sites.google.com/a/fws.gov/nwasc/). 
Currently the working version of the database is in PostgreSQL and can only be accessed from non-FWS computers. The long term goal is to create an improved database in Microsoft SQL server, which can be run on FWS computers. In the mean time while we redesign the schema, an Access database with the same format of the PostgresSQL schema is where we are aggregating the data (with the addition of track and camera tables). Other updates on the progress of this endeavor can be read in the BOEM bimonthly progress reports for this project or the [updates tab](https://sites.google.com/a/fws.gov/nwasc/updates?pli=1) on the website.

### **0. References**  
- O'Connell, A., Gardner, B., Gilbert, A., and Laurent, K. 2009. [Compendium of Avian Occurrence Information for the Continental Shelf Waters along the Atlantic Coast of the United States. Final Report](https://www.nodc.noaa.gov/archive/arc0070/0115356/1.1/data/0-data/SeabirdDatabaseFinalReport.pdf) to USFWS. USGS, Patuxent Wildlife Research Center.  
- Zipkin, Elise F., Leirness, Jeffery B., Kinlan, Brian P., O'Connell, Allan F., and Emily D. Silverman. 2014. [Fitting statistical distributions to sea duck count data: Implications for survey design and abundance estimation.](https://www.researchgate.net/publication/259163159_Fitting_statistical_distributions_to_sea_duck_count_data_Implications_for_survey_design_and_abundance_estimation) STATISTICAL METHODOLOGY 17:67–81. DOI: 10.1016/j.stamet.2012.10.002  
- Zipkin, Elise F., Kinlan, Brian P., Sussman, Allison, Rypkema, Diana, Wimer, Mark, and Allan F. O'Connell. 2015. [Statistical guidelines for assessing marine avian hotspots and coldspots: A case study on wind energy development in the U.S. Atlantic Ocean.](https://www.researchgate.net/publication/281667883_Statistical_guidelines_for_assessing_marine_avian_hotspots_and_coldspots_A_case_study_on_wind_energy_development_in_the_US_Atlantic_Ocean) BIOLOGICAL CONSERVATION 191:216-223. DOI: 10.1016/j.biocon.2015.06.035  
- USGS Atlantic Offshore Seabird Dataset Catalog [metadata](https://www.sciencebase.gov/catalog/file/get/56f15a47e4b0f59b85de0ac4?f=__disk__79%2F48%2Fa2%2F7948a2a46b78897b88f1ac8d1eeae171fd35d440&transform=1&allowOpen=true).  
- USGS Atlantic Offshore Seabird Dataset Catalog [summary and files](https://www.sciencebase.gov/catalog/item/56f15a47e4b0f59b85de0ac4).  
  
### **1. Collect datasets**   
This is an ongoing effort by FWS, NOAA, and BOEM. A progress table can be seen [here](https://sites.google.com/a/fws.gov/nwasc/progress-table). When a data set is recieved, put the data in a new folder named after the data set and year(s) surveyed. If that data set is part of a larger effort there should be a parent folder for that survey name and then folders for each data set within that parent folder. Please include a text document listing a point of contact for that data set and any other pertinent information. If you are able to obtain a report for that data set from the provider, include that in the folder as well. Please see the [data submission guidelines](https://github.com/USFWS/AMAPPS/blob/master/NWASC/Submission%20Guidelines%20for%20NWASC.rmd) for details about what should be requested. 

### **2. Quality control data**  
While the data should be cleaned by the data provider before submission, this isn't always the case. This will most likely be simple data checks (e.g. do species codes match those in the catalog, are the gps coordinates in latitude and longitude units, are certain data columns like count a number, etc.); however, more effort is sometimes required. For datasets where there is a clear survey design, yet the provider cannot supply one, an estimated track effort file needs to be made in order to segment that data for NOAA. Sometimes the lines are simple and straight forward, but if it is more complex, try to use an average of the data to create a line between commonly used start and stop points.  

### **3. Enter data into the database**  
There are several tables in the seabird schema; however, the most important ones are the observations, dataset, and transect tables. 
Track data is stored in the QGIS spatial portion of PostgreSQL. The dataset table is where most of the metadata for that dataset is gathered, most of this information can be found in the dataset report (if there is one). 

### **4. Check database integrity**  
After adding data, you should verify that the joins were successful and no existing data was altered in the process.

### **5. Submit data to users and archives**  
-  NCEI (NOAA National Centers for Environmental Information)/ NODC ([National Oceanographic Data Center](https://www.nodc.noaa.gov/))  
  - *Process:* Once the data has been entered into the NWASC database, the data are sent to the  NOAA National Centers for Environmental Information (NCEI) (Formerly NOAA National Oceanographic Data Center - NODC) to be archived. A past submission can be seen [here](http://www.nodc.noaa.gov/cgi-bin/OAS/prd/accession/0115356) (accessions_id: 0115356). Datasets that are already in the NODC can be found in the [DataSets in NODC file](https://sites.google.com/a/fws.gov/nwasc/archived-in-nodc).
    - All data-object-tables from the database need to be extracted and combined in one flat 'csv' file, [see old](http://www.nodc.noaa.gov/archive/arc0070/0115356/1.1/data/0-data/seabird_data_archive_NODC_30Dec2013.csv)  
    - Prepare a file with column descriptions, [see old](http://www.nodc.noaa.gov/archive/arc0070/0115356/1.1/data/0-data/seabird_data_structure_NODC_30Dec2013.csv)  
    - Prepare a FGDC record metadata file, [see old](http://www.nodc.noaa.gov/archive/arc0070/0115356/1.1/data/0-data/Atlantic%20Offshore%20Seabird%20Dataset%20Catalog_NODC%20Metadata_FGDC.xml)  
    - Report needs to be in 'pdf' format.  
    - The data should be submitted using the submission [website](https://www.nodc.noaa.gov/s2n/). 
  - *Scripts needed:* create_vw_data_output_nodc_dec2013 (SQL file to create NODC view excluding some datasets that shouldn't be public or were not designed for bird counts)
- OBIS ([Ocean Biogreographic Information System](http://www.iobis.org/))  
- BISON ([Biodiversity Information Serving Our Nation](http://bison.usgs.ornl.gov/#home))
  - Conversations about desired format are ongoing, but this will most likely be a segmented product like the one supplied to NOAA, instead of the raw data. We will nail down the details submitting AMAPPS data first, and then move to this larger database.  
- AKN ([Avian Knowledge Network](http://www.avianknowledge.net/))  
  - Conversations about desired format are ongoing, but this will most likely be a segmented product like the one supplied to NOAA, instead of the raw data  
- NOAA [avian modeling effort](http://portal.midatlanticocean.org/static/data_manager/metadata/html/avian_metadata.html) 
  - The NOAA Biogeography branch uses all of the data in the catalog in a predictive distribution model. 
  This involves processing all of the seabird data into segments. ([See segmentation script](https://github.com/USFWS/AMAPPS/tree/master/NWASC/Segmentation)). 

### **6. Handle data requests**  
Anyone can request the data. These requests will most likely be specific and require querying the database.  Make sure that you take note of the share level of the data when filling the request.    
- These can be found in the "data_requests" and "data_sent" folder in the "seabird_database" folder  
- They should include:  
  - a description of the request  
  - the date of the request 
  - the status of the request (filled/not yet filled, if filled the date should be included)
  - the code used to query the data   
  - the exported file that is sent to the requester  

### **7. Other**  
- The most recent relevant BOEM GIS data can be found [here](http://www.boem.gov/Renewable-Energy-GIS-Data/) (e.g. BOEM leases)  

