**Guidelines for submitting data to the Northwest Atlantic Seabird Catalog (NWASC)**   
===

1)	The data must be accompanied by a metadata file or documentation (e.g., a final report or proposed work/design for the project) describing how the data was collected and describing column names, measurement units, and ranges of acceptable inputs.   
* a.	Metadata for spatial data should conform to FGDC [guidelines](https://www.fgdc.gov/metadata/geospatial-metadata-standards)  
* b.	At a minimum metadata for bird observations should contain the following fields  
   + i.	Source of data including contact information  
   + ii.	Dates inclusive of all surveys submitted  
   + iii.	Type of platform used for observations: boat, aircraft, camera, fixed point ground survey, area-wide ground survey  
   + iv.	Preferred citation if data are made public  
   + v.	The link to the survey report if the report is published online  
   + vi.	Definition of fields transferred to NWASC including range of values and units  
   + vii.	Please list the survey method: Christmas bird count, bycatch, continuous time strip, discrete time horizon, discrete time strip, general observation, or targeted species survey.   
   + viii.	Please indicate whether the survey was derived effort, an original general observation, or original transect.  
  
2)	If species codes were used, please include documentation describing the codes. For example, a separate column or spreadsheet defining that COTE means common tern.  A list of our [species codes can be found on our GitHub webpage](https://github.com/USFWS/AMAPPS/blob/master/NWASC/Species_Codes.rmd). We do accept observations for other marine fauna and boats. ITIS codes are preferred.   
  
3)	The observation data should be accompanied by a transect design and, if available, an effort file. Effort files are usually the locations where the survey actually took place since sometimes an observation might not exactly be on the transect line or there might be a break in effort when an observer is not observing on a transect line. The effort helps clarify if there were no birds were seen in an area verses if the observer was not observing for a segment on a transect line.   
+ a.	Please provide this information in WGS84 datum or provide information on projection. Coordinates would be in decimal degrees (not UTMs)  
+ b.	Please provide beginning and ending points of transects  
+ c.	If effort is available please indicate the start and stop locations of when the observer was on or off effort and if an observation was off of the transect line (such as if observations were made in transit to the transect line)  
  
4)	Data should be provided in a commonly accessible formats; delimited with delimiter specified (e.g., ‘,’ ‘:’ ‘;’ ‘|’, tab, space), MS Excel, MS Access database, ArcGIS shapefile or geodatabase). Field descriptions can be found at the end of this document.   
  
5)	All data should have undergone quality checking and be free of errors (e.g., typos, date errors, mislabeled transects)  
  
6)	Data should not require any additional processing by our staff; such as if we had to back calculate a provider defined count per unit effort to define observation count.   
  
7)	No personal information (e.g., phone number or email) should be included in the data file (but see metadata requirements).  Any personally identifiable information will be stripped from the data before being loaded into the NWASC. Observer codes or initials are OK.  
  
8)	Data should be submitted via email to Kaycee Coleman, kaycee_coleman@fws.gov. If the attachment is too large to transfer via email, we can discuss further options.  
  
Detailed description of fields needed by the data provider:  
---

**Dataset table:**

field name | desciption    
----------|----------  
dataset_name (text) | if not defined we will supply one. These are usually modeled after the project name, the year the survey occurred, and the season, month, and/or day if there are more than one survey in a given year. Please define what a survey means to your project so that we can represent the data accordingly. (e.g. FWS_AMAPPS_summer_2017)
survey_type_cd (text)| The platform on which the survey occurred (e.g. boat (b), aircraft (a), camera (c), fixed point ground survey (f), area-wide ground survey (g))  
vehicle_name (text) | Optional. This is common for boat data but less common for other platforms.   
survey_method_cd (text)| The method of how the survey was conducted (e.g. Christmas bird count (cbc), bycatch (byc), continuous time strip (cts), discrete time horizon (dth), discrete time strip (dts), general observation (go), or targeted species survey (tss))  
dataset_type_cd (text)| The design of the survey (e.g. derived effort (de), original general observation (go), or original transect (ot))  
survey_width (number)| Planned width of survey in meters (e.g 300 m)  
individual_observer_survey_width (number) | in meters. An example would be if the whole survey width is 600 meters, but there are two observers on opposite sides of a platform only observing 300 meters in front of each.    
pooled_observations (yes/no) | An example would be if there are two observers observing at the same time on the same transect. Are their observations and the start and end of their efforts recorded separatly or are all of their observations pooled into one? If they have separate records for observations and effort start/stops then no, if it is unclear who was recording where or when then yes.  
survey_description (text)| Metadata for this dataset, and a summary of survey methods and acceptable ranges of each parameter (example: The Atlantic Marine Assessment Program for Protected Species (AMAPPS) Fish and Wildlife Service (FWS) fall 2014 dataset was conducted during the day between 10/6-10/22/2014 and ranges from Cape Canaveral, FL to the Maine/Canada border. Transects are located at 5’ (~5 nautical mile) intervals at the 1’ and 6’ minute latitude lines and extend from the coast to 30  meter depths or a maximum of 50 nautical miles offshore. Surveys are conducted on Kodiak aircrafts by teams of two observers, flying at 200 feet above ground at 110 knots. All seabirds, marine mammals, turtles, boats, and balloons within 400 meters of the observer are recorded. Distance from the observer to the animal is recorded where 0 = <200 meters or unknown, 1 = 0-100 m, 2 = 100-200 m, and 3 = >200 m which is off of the transect line being surveyed. Bird behavior is recorded as sitting or flying.  The number of individuals is recorded for each species. Weather condition is also recorded on a scale from 1 (worst) to 5 (best). Time is recorded in seconds from midnight and should not be converted.) 
sponsers (text) | if you would like to define who are the entities engaged and/or funding this work (e.g. FWS, NOAA, Navy, BOEM, etc.)  
dataset_citation (text)| How you would like users to cite your data.  
dataset_report (text)| A link to where the report on how the data were collected can be found online, in case the user needs further   information (e.g. [NMFS AMAPPS Annual Report](http://www.nefsc.noaa.gov/psb/AMAPPS/docs/NMFS_AMAPPS_2011_annual_report_final_BOEM.pdf))  


Detailed description of data fields needed by the provider:  
---  

**Observation table:**  

field name | desciption    
----------|----------   
source_transect_id (text)| If the dataset is based on a transect design, each observation should correspond to a unique transect name or number  
original_species_tx (text)| How you defined the species in your survey (common name, scientific name, code, ITIS number)  
spp_cd (text)| [four letter codes used in the seabird catalog](https://github.com/USFWS/AMAPPS/blob/master/NWASC/Species_Codes.rmd). If these are supplied but not checked against those used in the NWASC they should be accompanied by a secondary table descibing their meaning. 
obs_count_intrans_nb (number)| the number of individuals seen for a single species on a transect line at a given location 
obs_cound_general_nb (number)| the number of individuals seen off transect at a given location, such as in transit or outside of the survey width defined in guidelines. Offline observations are not needed but we do accept them.  
Latitude (number)| spatial location in decimal degrees (e.g. 33.51708) in WGS84 (if not, the projection needs to be defined)   
Longitude (number)| spatial location in decimal degrees (e.g. -78.68383) in WGS84 (if not, the projection needs to be defined)      
Date (date/time)| Ideally in year–month–day format (e.g. 2016-02-21)  
Time (date/time)| Ideally in hour:minute:second format (e.g. 13:05:20) where the hour is from 0-23 (we do accept seconds from midnight if it cannot be converted)    
Observer_tx (text)| The individual who was doing the observing. Observer initials or unique assigned numbers are ideal, full names will be abbreviated.   
  
*The following fields are optional in the observation table:*

field name | desciption    
----------|----------  
Animal_age_tx (text)| Age of animal (e.g. adult, juvenile, mixed, other, unknown, immature, subadult)     
Plumage_tx (text)| Description of the bird’s feathers  
Behavior_tx (text)| Behavior of the individual(s) (e.g. sitting, swimming, flying, diving, etc.)  
Travel_direction_tx (text)| direction of the observed animal (e.g. North, South, East, West)  
Heading_tx (text)| direction of the observed animal (e.g. 180 degrees)  
Flight_height_tx (text)| flight height of the observed animal (list units in text)  
Distance_to_animal_tx (text)| distance between the observer and the animal (list units in text)  
Angle_from_observer_nb (number)| angle between the observer and the animal   
Visibility_tx (text)| Visibility conditions such as how far one can see or the level of fogginess   
Weather_tx (text)| weather conditions such as sunny, rain, cloudy, etc.  
Seastate_beaufort_nb (number)| A scale relative to observation conditions from 0 (calm) to 6 (strong breeze) to 12 (hurricane force winds) (see [Beaufort Scale](https://en.wikipedia.org/wiki/Beaufort_scale))  
Wind_speed_tx (text)| wind speed (list units in text)  
Wind_direction_tx (text)| direction from which the wind is coming from  
Comments_tx (text)| Any comments the observer has about the observation  
Animal_sex_tx (text)| e.g. Male, Female, unknown, mixed  
Cloud_cover_tx (text)| describing cloud cover  
Association_tx (text)| if an observation is seen with another species or with a boat, however the observation of the separate entity should be a record of its own.  
Wave_height_tx (text)| wave height (list units in text)  
Observer_position (text)| Describing the observer position in the craft (e.g. right front, left rear, bridge)  
Glare_tx (text)| describing the glare off of the water  
Whitecaps_tx (text)| describing the state of the sea and degree of windiness  
Reel (text)| This is for camera observations only  
Observer_confidence_tx (text)| This is intended for camera observations  

**Track table:**   
**note**: *There is repetition in variables between tables due to different data providors recording information at different times (e.g. for each observation, once per transect, or for each track record). This does not mean that these need to be filled out for each table.* 

field name | desciption    
----------|---------- 
Date (date/time)| ideally in year–month–day format (e.g. 2016-02-21)       
Time (date/time)| ideally in hour:minute:second format (e.g. 13:05:20) where the hour is from 0-23      
Latitude (number)| spatial location in decimal degrees (e.g. 33.51708) in WGS84 (if not, the projection needs to be defined)        
Longitude (number)| spatial location in decimal degrees (e.g. -78.68383) in WGS84 (if not, the projection needs to be defined)    
Observer (text)| The individual who was doing the observing. Observer initials or unique assigned numbers are ideal, full names will be abbreviated.         
Observer_position (text)| Describing the observer position in the craft (e.g. right front, left rear, bridge)     
Seastate_beaufort_nb (number)| definition same as in observation table       
Comments (text)| definition same as in observation table       
Source_transect_id (text)| definition same as in observation table       
Point_type (text)| Record type; such as, start of transect or begin count (denoted by the code BEGCNT), end of transect or end count (denoted by code ENDCNT), pause on transect (which would need a ENDCNT followed by a BEGCNT when the pause is over and effort starts again), waypoint (denoted by code WAYPNT)   

**Transect table:**   
**note**: *There is repetition in variables between tables due to different data providors recording information at different times (e.g. for each observation, once per transect, or for each track record). This does not mean that these need to be filled out for each table.* 

field name | desciption    
----------|---------- 
Start_date (date/time)| start date of transect (ideally in year–month–day format (e.g. 2016-02-21))      
Start_time (date/time)| start time of transect (ideally in hour:minute:second format (e.g. 13:05:20) where the hour is from 0-23)       
Start_latitude(number)| start latitude of transect (e.g. 33.51708 in WGS84 (if not, the projection needs to be defined)        
Start_longitude (number)| start longitude of transect (e.g. -78.68383 in WGS84 (if not, the projection needs to be defined)    
End_date (date/time)| End date of transect (ideally in year–month–day format (e.g. 2016-02-21) )        
End_time (date/time)| End time of transect (ideally in hour:minute:second format (e.g. 13:05:20) where the hour is from 0-23) )        
End_latitude (number)| End latitude of transect (e.g. 33.51708 in WGS84 (if not, the projection needs to be defined)          
End_longitude (number)| End longitude of transect (e.g. -78.68383 in WGS84 (if not, the projection needs to be defined)         
Observer (text)| The individual who was doing the observing. Observer initials or unique assigned numbers are ideal, full names will be abbreviated.          
Observer_position (text)| Describing the observer position in the craft (e.g. right front, left rear, bridge)         
Speed_nb (number)| Speed the craft was traveling at in knots per hour  
Visability_tx (text)| definition same as in observation table       
Weather_tx (text)| definition same as in observation table       
Heading_tx (text)| direction the craft/vessel was heading in  
Seastate_beaufort_nb (number)| definition same as in observation table       
Wind_speed_tx (text)| definition same as in observation table       
Wind_dir_tx (text)| definition same as in observation table           
Comments_tx (text)| definition same as in observation table       


