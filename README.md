# AMAPPS

[id]: http://www.nefsc.noaa.gov/psb/AMAPPS/  
This repository contains the scripts to QA/QC the USFWS Atlantic Marine Assessment Program for Protected Species ([AMAPPS][id]) aerial data and prepare it for import into the USFWS AMAPPS SQL Server database and the USFWS maintained Northwest Atlantic Seabird Catalog (NWASC). 

Read Me for AMAPPS data management
========================================================
Written by: Kaycee Coleman   
Created: Nov. 2015     

For USFWS MB personel, all documentation is housed in M:/seabird_database folder and for now all working code is in the fs1/SeaDuck/NewCodeFromJeff_20150720 folder. This repository and QA/QC scripts are a work in progress, not a finished product  

1) Understanding the data
--------------------------------------------------------
[id2]: https://my.usgs.gov/confluence/display/mbmdl/Data+lifecycle+development+for+Migratory+Bird+surveys+Home  
**For USFWS MB personel, in seabird_database/documentation Read:**
- SeabirdSurvey_SOP.doc
- seabirds key tables structure Aug2013
- Final and progress reports (in Reports folder)
- StepsForOutput.doc
- Seabird Database Quality Checking and Editing_Jan26 2012.doc
- Data Proofing.doc
- Editing\_Database\_File_Registry.doc
- In addition it might help to look at the Data lifecycle development for Migratory Birds surveys [website][id2] and read the standard operating procedures. You will need premission to log onto this site. 

[id9]: https://www.researchgate.net/publication/281667883_Statistical_guidelines_for_assessing_marine_avian_hotspots_and_coldspots_A_case_study_on_wind_energy_development_in_the_US_Atlantic_Ocean
[id10]: https://www.researchgate.net/publication/259163159_Fitting_statistical_distributions_to_sea_duck_count_data_Implications_for_survey_design_and_abundance_estimation

**References:**    
- O'Connell, A., Gardner, B., Gilbert, A., and Laurent, K. 2009. Compendium of Avian Occurrence Information for the Continental Shelf Waters along the Atlantic Coast of the United States. Final Report to USFWS. USGS, Patuxent Wildlife Research Center.
- Zipkin, Elise F., Leirness, Jeffery B., Kinlan, Brian P., O'Connell, Allan F., and Emily D. Silverman. 2014. [Fitting statistical distributions to sea duck count data: Implications for survey design and abundance estimation][id10]. STATISTICAL METHODOLOGY 17:67–81.  DOI: 10.1016/j.stamet.2012.10.002
- Zipkin, Elise F., Kinlan, Brian P., Sussman, Allison, Rypkema, Diana, Wimer, Mark, and Allan F. O'Connell. 2015. [Statistical guidelines for assessing marine avian hotspots and coldspots: A case study on wind energy development in the U.S. Atlantic Ocean][id9]. BIOLOGICAL CONSERVATION 191:216-223. DOI: 10.1016/j.biocon.2015.06.035 



2) Where to obtain survey data for processing 
--------------------------------------------------------
[id3]: https://connect.doi.gov/fws/Portal/acjv/seabird/SitePages/Home.aspx
- AMAPPS data can be found on the SharePoint [site][id3]. You will need premission to log onto this site. Download all of the processed observation and track files and save them in the Survey_Data/AMAPPS/AMAPPS_year_mo folder.


3) Quality Control / Data Processing in R and GIS 
--------------------------------------------------------
**Process:**  
- This section describes how to QA/QC the data using R, ArcMap, and Python within ArcMap. You will run "part1", check the shapefiles in ArcMap, save those files, then run "part2" of the scripts. 

**Scripts needed:**  
- processSurveyData_part1.R -> This will load packages and functions. You should alter the beginning of this file for surveyFolder and yearLabel. This will clean the data and generate temporary shapefiles.  
              *WARNING*: The "py.exe" will be dependent on your ArcGIS version (e.g. 10.3) and you might also have installer issues (64 bit vs. 32 bit) -- to test this you can go into the python window in ArcGIS and type *import sys* -> hit enter -> then type *print(sys.version)*. You might also need to check your Rstudio version (Tools-Options). Issues like this might also occur with the 'RODBC' package, odbcDriverConnect function.  
    *Within this script*:   
    - RProfile.R loads neccessary librarys and runs the following functions: 
        - addBegEnd\_GISeditObsTrack.R -> this is for after the GIS edits, if points were deleted and new BEG/END counts need to be added
        - addBegEnd\_Obs.R -> this adds BEG/END counts if needed
        - addCoch.R -> Adds a condition change (COCH) row when one was not reported with condition value "0" and count "0"
        - checkBEGCNTandENDCNTnumbers.R -> Reports transects with errors in BEGCNT and ENDCNT rows
        - checkConditionChange.R 
        - combineObsTrack.R -> combines the observation and track files. If you see an error message such as **"Missing track file and manual seconds fix required"**, then this needs to be fixed before moving on. If a track is not available for an observer, for example the pilot track is available for that date but not the second observer's track, then the pilot's track will be used here.     
              - combineByName.R -> combines dataframes by name  
        - commonErrors.R -> fix basic errors 
        - conditionCodeErrorChecks.R 
        - createBandBehavior.R -> create band and behavior columns 
        - getObsFiles.R -> reads in the crew#_mmddyyy_birds.txt or .asc files and turns them into the "obs" and "Obs.Crew#" tables
        - getTrackFiles.R -> reads in the track files
        - fixMixed.R -> break mixed code row into multiple rows for each code  
        - fixSeconds.R -> fixes seconds errors in observation files
        - GPSFix.R -> fix GPS errors  
        - obsFilesErrorChecks.R -> checks basic errors  
        - runArcGISpy.R -> runs the python script that generates ArcGIS shapefiles  
        
    - ObsFilesFix\_yearlabel.R This script is unique to each input year/season file and fixes errors in the observation files:    
        a) Fixes incorrect type codings (species and start and stop points of transects)    
        b) Fix condition change errors (add a record for when the weather condition changes)    
        c) Breaks apart mixed flock records (create individual records for each species observed)  
        d) Flag data for errors      
          - flag1: distance from survey transect line is greater than 2 kilometers   
          - flag2: bearing error when the difference of bearing[i] - bearing[i-1] greater than 100. An example of this would be when the plane might have taken a turn or did a loop on transect to get a closer look at something.   
          - flag3: bearing errors of transLat equal to 0, or sbearing less than 70, or sbearing within the range of 110 to 250, or sbearing greater than 290  
          - onLand: points that fall on land or within the land buffer. The majority of these should be cut, but they are visually inspected since the coastline or islands we are comparing the point to might not be perfectly accurate. 
        
    - GISeditObsTrack (python file used in ArcMap to fix spatial errors in the data)
- processSurveyData_part2.R. After the manual GIS edits, this rechecks the data for errors caused in manual editing and combines the files for entry into the Atlantic_Coast_Surveys and NWASC databases.
    - creates final_ .csv
    - creates temp observation and track files for add2database.R
    - updates Atlantic_Coast_Surveys_MiscObservations.csv
    - updates Atlantic_Coast_Surveys_BalloonsObservations.csv
    - updates Atlantic_Coast_Surveys_BoatObservations.csv
    - creates Transect Information table for access database
    - adds covariates (depth, slope, distance to coast) to observation data  
    - calculated distance flown and average condition for each transect
 

**Files Needed:**  
- AMAPPS observation files (downloaded from SharePoint)
- AMAPPS transect files (downloaded from SharePoint)
- NWASC_temp database lu_species table (list of all of the species codes used, path defined as dbpath in the process scripts)
- ObsFilesFix\_yearlabel.R   
        - Creating yearlab\_ObsFilesFix.R: You will add to this script as you run through the error checks and find new errors. The *AMAPPS\_yearlab\_AOUErrors.xlsx* and *AMAPPS\_yearlab\_ObsFileErrors.xlsx* generated in the *DataProcessing -> Surveys -> AMAPPS -> AMAPPS\_yearlab* folder will help inform you of which errors to fix in the yearlab\_ObsFilesFix.R script. These are often typos. You may need to listen to the corresponding WAV file (on the SharePoint site) to find out what the observer was trying to enter. Common errors should be included in the yearlab\_ObsFilesFix.R script prior if you need to look them up for reference (e\.g\. changing TOWER to code TOWR).  Also if there are corrections in the pilot/observer notes these corrections should be included in the yearlab\_ObsFilesFix.R script.  
- GISeditObsTrack_template (ArcGIS ArcMap Document)  
        - used to create shapefiles for each crew/day
- atlanticCoastline_buffer_halfNM (shapefile)  
        - used to check if points are on land
- amapps_transects_new2014 (shapefile)   
        - used to check if transects are labeled incorrectly or if points are too far off a transect  


**Manual editing in GIS (after run_processSurveyData_part1.R and before processSurveyData_part2.R):**  

  a) open the shapefiles created in part1    
  b) visually inspect each crew/day shapefile (check the points flagged that are on land, track points that aren't on a transect, points were the pilots are not flying a straight line where they could be looping back around, etc.)  

 
>   Flag color coding:  
>    0,0,0 = grey = no error  
>    0,0,1 = purple = bearing error  
>    0,1,0 = yellow = distance error  
>    1,0,0 = red = start or end point  
>    0,1,1 = green = start or end point and bearing error  
>    1,1,1 = green = start or end point, bearing, and distance  
>    1,1,0 = green = start or end point and distance error  
>    1,0,1 = purple = distance and bearing error   

  c) delete points you find unfit, they will be saved in a csv format in part2. These points should be track file points NOT observation points. You can tell this by checking the information when you click on that point. If you find an issue with an observation point be certain that it is an error before deleting it.    
 - Manually delete suspicious points  
        - First use the information tool to check if it is an observation or a waypoint. If it is an observation it is most likely a true data point.  The land maps in ArcMap may not be accurate.  
        - As a rule of thumb, if there are less than 6 points crossing an Island most likely you can leave these. You are trying to target larger areas across land. The island topography could be off.  
        - Use the editor tool  
        - Click on the suspicious point  
        - Hit delete  

d) save each crew/day shapefile in an edited_shapefiles folder  
- Save each edited layer as a shapefile  
        - Right click on layer  
        - Click on data  
        - Click on export data   
        - Click on the folder icon and  
        - Switch 'save type as' to shapefile  

**Outputs:**  
a) Part1  
- temporary files to show you errors that need fixing (missing files, errors in the data, etc.)
- shapefiles in temp_shapefiles folder 
- obstrack R workspace  
- obstack part1 file  

b) GIS editing  
- edited shapefiles in edited_shapefiles folder  

c) Part2  
- Transect information file  
- Observation file  
- Track file  
- Offline observations file  
- Send to NOAA file (marine mammals, fish, etc.)  
- Deleted points file (from compairing temp. and edited shapefiles)  
- Obstrack final file (processed/ cleaned data including all the track and observation information, even offline observations - this goes to NWASC)  
- Missing Observations file (make sure you check this to make sure there isn't data missing that you can fix)
- Missing Tracks file (make sure you check this to make sure there isn't data missing that you can fix)
- Crew Summary


4) Entering the data in AMAPPS atlantic seabirds SQL Server database (formerly the Access "Atlantic_Coast_Surveys" database)  
--------------------------------------------------------
**Process:**  
- The AMAPPS database houses all of the AMAPPS data but excludes nonbirds (except for boats). Nonbird and offline data are saved seperately or in the Misc_observations table of the database. The database includes tables for  "Crew_Information", "Observations", "Survey_Information", "Tracks", and "Transect_Information". 

**Scripts needed:**  
-- formerly Add2Database2.R (formats the data to go into each table and adds the data to the access "Atlantic_Coast_Surveys" database), a new script is being written to enter the data into SQL Server     

To access the atlantic seabirds SQL Server database [follow the directions listed here]
(https://my.usgs.gov/confluence/display/mbmdl/Accessing+the+data).  You will need permission to access the database directly.    

5) Reformating and entering the data in the NWASC Database 
--------------------------------------------------------
**Process:**  
- All offline, bird, and nonbird data are entered into the NWASC.   
- Segmentation of the data for NOAA happens once the data is in the NWASC on all of the NWASC data at the same time (not by dataset).

**If you are also managing the NWASC, see NWASC folder to continue**

>*Disclaimer:*  
>The United States Fish and Wildlife Service (FWS) GitHub project code is provided on an "as is" basis and the user assumes responsibility for its use. FWS has relinquished control of the information and no longer has responsibility to protect the integrity, confidentiality, or availability of the information. Any reference to specific commercial products, processes, or services by service mark, trademark, manufacturer, or otherwise, does not constitute or imply their endorsement, recommendation or favoring by FWS. The FWS seal and logo shall not be used in any manner to imply endorsement of any commercial product or activity by FWS or the United States Government. 
