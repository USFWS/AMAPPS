/*
This script creates the Northwest Atlantic Seabird Catalog Schema
and populates a few non-spatial tables

created April 2017
by K. Coleman

This script will continue to be updated when adding new datasets to the dataset table
or for most other additions or changes made to tables other than observations, transect, or track
*/

---------------------
-- define database --
---------------------
USE NWASC;
GO
--


---------------------------
-- create look up tables --
---------------------------

--create and populate dataset type table
CREATE TABLE lu_dataset_type (
	dataset_type_cd nchar(2) not null, 
	dataset_type_ds nvarchar(30) not null,
	Primary Key (dataset_type_cd)
);
GO

INSERT INTO lu_dataset_type (dataset_type_cd,dataset_type_ds)
	VALUES
	('de','derived effort'),
	('og','original general observation'),
	('ot','original transect');


--create and populate people table
CREATE TABLE lu_people (
	[user_id] smallint not null,
	name nvarchar(50) null,
	affiliation nvarchar(50) null,
	work_email_only nvarchar(50) null,
	active_status nchar(10) null,
	Primary Key ([user_id])
);
GO

INSERT INTO lu_people([user_id], name, affiliation, active_status,work_email_only)
	VALUES 
	(1,'Mark Wimer','USGS','active','mwimer@usgs.gov'),
	(2,'Allison Sussman','USGS','not active',NULL),
	(3,'Andrew Gilbert','BRILOON','active','andrew.gilbert@briloon.org'),
	(4,'Tim Pascoe',NULL,NULL,NULL),
	(5,'Thomas de Lange Wenneck', NULL,NULL,NULL),
	(6,'Henrik Skov',NULL,NULL,NULL),
	(7,'David Divins','NOAA',NULL,NULL),
	(8,'Geoffrey LeBaron','Audubon',NULL,NULL),
	(9,'David Wiley','NOAA',NULL,'david.wiley@noaa.gov'),
	(10,'Becky Harris','MA Audubon',NULL,NULL),	
	(11,'Richard Veit','CUNY','active','Richard.Veit@csi.cuny.edu'),
	(12,'Larry Poppe','USGS',NULL,NULL),	
	(13,'Terry Orr',NULL,NULL,NULL),
	(14,'Mark Koneff','USFWS','active','mark_koneff@fws.gov'),
	(15,'Doug Forsell','USFWS','not active',NULL),
	(16,'Carina	Gjerdrum',NULL,'active',NULL),
	(17,'Todd O''Brien','NOAA',NULL,NULL),	
	(18,'Bruce Peterjohn','USGS',NULL,NULL),
	(19,'David Potter','NOAA',NULL,NULL),	
	(20,'J. Christopher	Haney','Defenders', NULL,NULL),	
	(21,'David Mizrahi','NJ Audubon', NULL,NULL),	
	(22,'David Lee',NULL,NULL,NULL),			
	(23,'Erin LaBrecque','Duke',NULL,NULL),	
	(24,'R. A. Rowlett',NULL,NULL,NULL),			
	(25,'Malcolm Gordon','UCLA',NULL,NULL),	
	(26,'R. Haven Wiley','UNC', NULL,NULL),	
	(27,'David Hyrenbach','U Washington',NULL,NULL),
	(28,'Hal Whitehead','DAL',NULL,NULL),	
	(29,'Kevin Powers', NULL,NULL,NULL),			
	(30,'Lance Garrison','NOAA',NULL,NULL),	
	(31,'Stephanie Schmidt','Manomet',NULL,NULL),
	(32,'Brian Patteson',NULL,NULL,NULL),			
	(33,'Linda Welch','USFWS','active','Linda_Welch@fws.gov'),
	(34,'Sarah Wong','DAL',NULL,NULL),
	(35,'Bob Raftovich','USFWS','active','robert_raftovich@fws.gov'),
	(36,'Kim Urian','EC RR',NULL,NULL),	
	(37,'Odd Aksel Bergstad','IMR',NULL,NULL),
	(38,'Peter Stevick',NULL,NULL,NULL),		
	(39,'Nicholas Wolff','U Maine',NULL,NULL),	
	(40,'Douglas Pfeister', NULL,NULL,NULL),	
	(41,'Kristopher	Winiarski', NULL,NULL,NULL),	
	(42,'Todd Hass','ECY WA',NULL,NULL),	
	(43,'Julie Ellis','Tufts',NULL,NULL),
	(44,'Allan O''Connell','USGS','active','aoconnell@usgs.gov'),
	(45,'Brian Kinlan','NOAA','not active',NULL),
	(46,'Beth Gardner',NULL,'active',NULL),
	(47,'Elise Zipkin',NULL,'active',NULL),
	(48,'Nick Flanders','NCSU',NULL,NULL),	
	--no 49, need to check and see if I can reassign 
	(50,'M. Tim	Jones','USFWS','active','tim_jones@fws.gov'),
	(51,'Melanie Steinkamp','USFWS','active','melanie_steinkamp@fws.gov'),
	(52,'Elizabeth Josephson','NOAA','active','elizabeth.josephson@noaa.gov'),
	(53,'Debra Palka','NOAA',NULL,NULL),	
	(54,'Holly Goyert','UMASS','active','hgoyert@umass.edu'),
	(55,'Mike Simpkins','NOAA',NULL,NULL),	
	(56,'Gary Buchanan', NULL,NULL,NULL),	
	(57,'Shannon Beliew','USGS', 'active','sbeliew@usgs.gov'),
	(58,'Emily Silverman','USFWS', 'active','emily_silverman@fws.gov'),
	(59,'Jeff Leirness','NOAA', 'active','jeffery.leirness@noaa.gov'),
	(60,'Pam Loring','USFWS','active','pamela_loring@fws.gov'),
	(61,'Julia Willmot','Normandeu', 'active','jwillmott@normandeau.com'),
	(62,'Tim White','BOEM', 'active','timothy.white@boem.gov'),
	(63,'Aaron Svedlow','Tetratech', 'not active',NULL),
	(64,'Kaycee Coleman','USFWS', 'active','kaycee_coleman@fws.gov'),
	(65,'David Bigger','BOEM','active','david.bigger@boem.gov'),
	(66,'Matt Nixon','Maine.gov','active','Matthew.E.Nixon@maine.gov'),
	(67,'Scott Anderson','NC Wildlife','active','scott.anderson@ncwildlife.org'),
	(68,'Arliss Winship','NOAA','active','Arliss.Winship@noaa.gov'),
	(69,'Fayvor Love','Point Blue','active','flove@pointblue.org'),
	(70,'Jim Paruk','BRILOON','active','jim.paruk@briloon.org'),
	(71,'Tony Diamond','University of New Brunswick','active',NULL),
	(72,'Tom White','USFWS','active','thomas_white@fws.gov'),
	(73,'Rob Serafini','Point Blue','active','rserafini@pointblue.org'),
	(74,'Caleb Spiegel','USFWS','active','caleb_spiegel@fws.gov'),
	(75,'Meghan Sadlowski','USFWS','active','meghan_sadlowski@fws.gov'),
	(76,'Scott Johnston','USFWS','active','scott_johnston@fws.gov'),
	(77,'Randy Dettmers','USFWS','active','randy_dettmers@fws.gov'),
	(78,'Jo Anna Lutmerding','USFWS','active','jo_lutmerding@fws.gov'),
	(79,'Kaye London','USFWS','active','kaye_london@fws.gov'),
	(80,'Andrew Allyn','UMass','active',NULL),
	(81,'Sarah Yates','USFWS','active','sarah_yates@fws.gov');
/* 
update lu_people
set name = 'Jo Anna Lutmerding'
where [user_id] = 78
*/
-- select * from lu_people where active_status = 'active'
select * from lu_species2
--create and populate share level table
CREATE TABLE lu_share_level (
	share_level_id tinyint not null,
	share_level_ds nvarchar(250) not null,
	PRIMARY KEY(share_level_id)
);
GO 

INSERT INTO lu_share_level(share_level_id, share_level_ds)
	VALUES
	(0,'we do not have the data, need to request or request in progress'),
	(1,'not shared: Due to sensitivity concerns. dataset is restricted temporarily; remove in near future or share at some level. Do not share, do not send data to external repositories. NOTE: we cannot legally deny valid data requests.'),
	(2,'limited use: Allow use in summaries and visualizations (maps, graphs) without specific information. Allow same general use by AKN. (AKN Level 2)'),
	(3,'limited use (AKN+): Same as level 2, except allow others to request the dataset through AKN.  (AKN Level 3)'),
	(4,'limited use (AKN++): Same as level 3, except the AKN will display more info (all "Darwin Core" elements) and share with several bioinformatic efforts.  (AKN Level 4)'),
	(5,'full data available: Allow use of all data except observer names and contact information. AKN will also receive all data elements (see list).  (AKN Level 5)'),
	(6,'unobtainable or nonexistant'),
	(7,'this data is part of another dataset and while there was an independent name the data are not independent'),
	(9,'acquired but not in the database and quality control not started'),
	(99,'in progress');
--

-- create and populate species type table
CREATE TABLE lu_species_type(
	species_type_id tinyint not null, 
	species_type_ds nvarchar(60) not null,
	PRIMARY KEY(species_type_id)
);
GO 
--

INSERT INTO lu_species_type(species_type_id, species_type_ds)
	VALUES
	(1,'birds'),
	(2,'cetaceans'),
	(3,'sea turtles'),
	(4,'fish'),
	(5,'other (bats, polar bears, plants, man made objects, etc.)'),
	(6,'bugs'),
	(7,'boats'),
	(8,'non-seabirds');
/*
update lu_species_type
set species_type_ds = 'landbirds'
where species_type_id = 8

select * from lu_species_type
*/
--

-- create species table
CREATE TABLE lu_species (
	spp_cd nvarchar(4) not null,
	species_type_id tinyint not null,
	common_name nvarchar(200) not null,
	[group] nvarchar(100) null,
	[order] nvarchar(100) null,
	family nvarchar(100) null,
	subfamily nvarchar(100) null,
	genus nvarchar(100) null,
	species nvarchar(100) null,
	[changes] nvarchar(200) null,
	ITIS_id int null,
	PRIMARY KEY(spp_cd),
	FOREIGN KEY(species_type_id) REFERENCES lu_species_type(species_type_id)
);
GO

INSERT INTO lu_species(
	species_type_id,spp_cd,	common_name, [group], genus, species, ITIS_id, [changes])
	VALUES
	(1,'ABDH','American Black Duck X Mallard Hybrid','Anas rubripes x platy.','Anas', NULL, NULL, NULL),
	(1,'ABDU','American Black Duck', NULL,'Anas','rubripes',175068, NULL),
	(1,'AMBI','American Bittern',NULL,'Botaurus','lentiginosus',174856, NULL),
	(1,'AMCO','American Coot',NULL,'Fulica','americana',176292, NULL),
	(1,'AMGP','American Golden Plover',NULL,'Pluvialis','dominica',176564, NULL),
	(1,'AMOY','American Oystercatcher',NULL,'Haematopus','palliatus',176472, NULL),
	(1,'AMWI','American Wigeon',NULL,'Mareca','americana',175094,'Formerly places in the genus Anas'),
	(1,'AMWO','American Woodcock',NULL,'Scolopax','minor',176580, NULL),
	(1,'ANHI','Anhinga anhinga',NULL,'Anhinga','anhinga',174755, NULL),
	(1,'APLO','Arctic Loon/Pacific Loon','Gavia arctica/pacifica',NULL,NULL,NULL, NULL),
	(1,'ARLO','Arctic Loon',NULL,'Gavia','arctica',174471, NULL),
	(1,'ARTE','Arctic Tern',NULL,'Sterna','paradisaea',176890, NULL),
	(1,'ATPU','Atlantic Puffin',NULL,'Fratercula','arctica',177025, NULL),
	(1,'AUSH','Audubon''s Shearwater',NULL,'Puffinus','iherminieri',174561, NULL),
	(1,'AWPE','American White Pelican',NULL,'Pelecanus','erythrorhynchos',174684, NULL),
	(1,'BAGO','Barrow''s Goldeneye',NULL,'Bucephala','islandica',175144, NULL),
	(1,'BASA','Baird''s Sandpiper',NULL,'Calidris','bairdii',176655, NULL),
	(1,'BARO','Barolo Shearwater',NULL,'Puffinus','baroli',824117, NULL),
	(1,'BBPL','Black-bellied Plover',NULL,'Pluvialis','squatarola',176567, NULL),
	(1,'BBSP','Black-bellied Storm-petrel',NULL,'Fregetta','tropica',174655, NULL),
	(1,'BCNH','Black-crowned Night-Heron',NULL,'Nycticorax','nycticorax',174832, NULL),
	(1,'BCPE','Black-capped Petrel',NULL,'Pterodroma','hasitata',174567, NULL),
	(1,'BEPE','Bermuda Petrel',NULL,'Pterodroma','cahow',174568, NULL),
	(1,'BFAL','Black-footed Albatross',NULL,'Diomedea','nigripes',174516, NULL),
	(1,'BHGU','Common Black-headed Gull',NULL,'Larus','ridibundus',176835, NULL),
	(1,'BLGU','Black Guillemot',NULL,'Cepphus','grylle',176985, NULL),
	(1,'BLKI','Black-legged Kittiwake',NULL,'Rissa','tridactyla',176875, NULL),
	(1,'BLNO','Black Noddy',NULL,'Anous','minutus',176944, NULL),
	(1,'BLOY','Black Oystercatcher',NULL,'Haematopus','bachmani',176475, NULL),
	(1,'BLSC','Black Scoter',NULL,'Melanitta','nigra',175171, NULL),
	(1,'BLSK','Black Skimmer',NULL,'Rynchops','niger',554447, NULL),
	(1,'BLSP','Black Storm-petrel',NULL,'Oceanodroma','melania',174640, NULL),
	(1,'BLTE','Black Tern',NULL,'Chlidonias','niger',176959, NULL),
	(1,'BNST','Black-necked Stilt',NULL,'Himantopus','mexicanus',176726, NULL),
	(1,'BOGU','Bonaparte''s Gull',NULL,'Larus','philadelphia',176839, NULL),
	(1,'BRAN','Brant',NULL,'Branta','bernicla',175011, NULL),
	(1,'BRBO','Brown Booby',NULL,'Sula','leucogaster',174704, NULL),
	(1,'BRNO','Brown Noddy',NULL,'Anous','stolidus',176941, NULL),
	(1,'BRPE','Brown Pelican',NULL,'Pelecanus','occidentalis',174685, NULL),
	(1,'BRSP','Band-rumped Storm-petrel',NULL,'Oceanodroma','castro',174636, NULL),
	(1,'BRTE','Bridled Tern',NULL,'Sterna','anaethetus',176897, NULL),
	(1,'BTGU','Black-tailed Gull',NULL,'Larus','crassirostris',176831, NULL),
	(1,'BUFF','Bufflehead',NULL,'Bucephala','albeola',175145, NULL),
	(1,'BUPE','Bulwer''s Petrel',NULL,'Bulweria','bulweria',554144, NULL),
	(1,'BVSH','Black-vented Shearwater',NULL,'Puffinus','opisthomelas',554396, NULL),
	(1,'BWTE','Blue-winged Teal',NULL,'Spatula','discors',175086,'Spatula discors orphna recorganized by AOU 1957, but validity doubtful. Formerly genus Anas'),
	(1,'CAAU','Cassin''s Auklet',NULL,'Ptychoramphus','aleuticus',177013, NULL),
	(1,'CAEG','Cattle Egret',NULL,'Bubulcus','ibis',174803, 'Not recognized by del Hoyo et al. (1992) or Clements (2000) or Howard and Moore (2003), but included in treatments Peters (1979)'),
	(1,'CAGU','California Gull',NULL,'Larus','californicus',176829, NULL),
	(1,'CANG','Canada Goose',NULL,'Branta','canadensis',174999, NULL),
	(1,'CANV','Canvasback',NULL,'Aythya','valisineria',175129, NULL),
	(1,'CATE','Caspian Tern',NULL,'Sterna','caspia',176924, NULL),
	(1,'CHAR','Unidentified Charadriiform','Charadriiformes',NULL,NULL,176445, NULL),
	(1,'CLRA','Clapper Rail',NULL,'Rallus','longirostris',176209,'Formerly considered conspecific with Rallus longirostris'),
	(1,'COEI','Common Eider',NULL,'Somateria','mollissima',175155, NULL),
	(1,'COGA','Common Gallinule',NULL,'Gallinula','galeata',708108, NULL),
	(1,'COGO','Common Goldeneye',NULL,'Bucephala','clangula',175141, NULL),
	(1,'COLO','Common Loon',NULL,'Gavia','immer',174469, NULL),
	(1,'COME','Common Merganser',NULL,'Mergus','merganser',175185, NULL),
	(1,'COMO','Common Moorhen',NULL,'Gallinula','chloropus',176284, NULL),
	(1,'COMU','Common Murre',NULL,'Uria','aalge',176974, NULL),
	(1,'COPE','Cook''s Petrel',NULL,'Pterodroma','cookii',554395, NULL),
	(1,'COSH','Cory''s Shearwater',NULL,'Calonectris','diomedea',203446, NULL),
	(1,'COSN','Common Snipe',NULL,'Gallinago','gallinago',176700, NULL),
	(1,'COTE','Common Tern',NULL,'Sterna','hirundo',176888, NULL),
	(1,'CVSH','Cape Verde Shearwater',NULL,'Calonectris','edwardsii',723253, NULL),
	(1,'DASC','Unidentified Dark scoter - black or surf',NULL,NULL,NULL,NULL, NULL),
	(1,'DCCO','Double-crested Cormorant',NULL,'Phalacrocorax','auritus',174717, NULL),
	(1,'DOVE','Dovekie',NULL,'Alle','alle',176982, NULL),
	(1,'DOWI','Unidentified Dowitcher spp.','Limnodromus griseus or L. scolopaceus','Limnodromus',NULL,176674, NULL),
	(1,'DUNL','Dunlin',NULL,'Calidris','alpina',176661, NULL),
	(1,'EISC','Unidentified Eider/Scoter spp.','Melanitta/Somateria spp.',NULL,NULL,NULL, NULL),
	(1,'EUOY','Eurasian Oystercatcher',NULL,'Haematopus','ostralegus',176469, NULL),
	(1,'EUSP','European Storm-petrel',NULL,'Hydrobates','pelagicus',174663, NULL),
	(1,'EUWI','Eurasian Wigeon',NULL,'Mareca','penelope',175092,'Formerly placed in the genus Anas'),
	(1,'FEPE','Fea''s Petrel (aka Cape Verde Petrel)',NULL,'Pterodroma','feae',562557, NULL),
	(1,'FFSH','Flesh-footed Shearwater',NULL,'Puffinus','carneipes',174548, NULL),
	(1,'FOTE','Forster''s Tern',NULL,'Sterna','forsteri',176887, NULL),
	(1,'FRGU','Franklin''s Gull',NULL,'Larus','pipixcan',176838, NULL),
	(1,'FTSP','Fork-tailed Storm-petrel',NULL,'Oceanodroma','furcata',174625, NULL),
	(1,'GADW','Gadwall',NULL,'Mareca','strepera',175073,'No extant subspecies. Peters (1979), Clements (2000), and Howard and Moore (2003) recognize Mareca strepera couesi, now extinct. Formerly placed in the genus Anas'),
	(1,'GBBG','Great Black-backed Gull',NULL,'Larus','marinus',176815, NULL),
	(1,'GBHE','Great Blue Heron',NULL,'Ardea','herodias',174773, NULL),
	(1,'GBHG','Unidentified Great Black-backed/Herring Gull','Larus marinus/argentatus',NULL,NULL,NULL, NULL),
	(1,'GBTE','Gull-billed Tern',NULL,'Sterna','nilotica',176926, NULL),
	(1,'GHGH','Glaucous Gull X Herring Gull (hybrid)','Larus hyperboreus X argentatus',NULL,NULL,NULL, NULL),
	(1,'GLGU','Glaucous Gull',NULL,'Larus','hyperboreus',176808, NULL),
	(1,'GLIB','Glossy Ibis',NULL,'Plegadis','falcinellus',174924,'Formerly three subspecies recognized (Peters 1931), but now recognized as monotypic'),
	(1,'GOME','Unidentified Goldeneye or Merganser',NULL,NULL,NULL,NULL, NULL),
	(1,'GRCO','Great Cormorant',NULL,'Phalacrocorax','carbo',174715, NULL),
	(1,'GREG','Great Egret',NULL,'Ardea','alba',554135, NULL),
	(1,'GRFR','Great Frigatebird',NULL,'Fregata','minor',174766, NULL),
	(1,'GRHE','Green Heron',NULL,'Butorides','virescens',174793, NULL),
	(1,'GRSC','Greater Scaup',NULL,'Aythya','marila',175130, NULL),
	(1,'GRSH','Greater Shearwater',NULL,'Puffinus','gravis',174549, NULL),
	(1,'GRSK','Great Skua',NULL,'Stercorarius','skua',660059, NULL),
	(1,'GRYE','Greater Yellowlegs',NULL,'Tringa','melanoleuca',176619, NULL),
	(1,'GUTE','Unidentified Small Gull/Tern',NULL,NULL,NULL,NULL, NULL),
	(1,'GWFG','Greater White-fronted Goose',NULL,'Anser','albifrons',175020, NULL),
	(1,'GWGU','Glaucous-winged Gull',NULL,'Larus','glaucescens',176814, NULL),
	(1,'GWTE','Green-winged Teal',NULL,'Anas','crecca',175081, NULL),
	(1,'HADU','Harlequin Duck',NULL,'Histrionicus','histrionicus',175149,'Monotypic. Howard and Moore (2003) list subspecies H. h. histionicus and H. h. pacificus but validity doubtful'),
	(1,'HAPE','Hawaiian Petrel',NULL,'Pterodroma','sandwichensis',562561, NULL),
	(1,'HEPE','Herald/Trinidad Petrel','heraldica and arminjoniana subspecies','Pterodroma','arminjoniana',NULL, NULL),
	(1,'HERG','Herring Gull',NULL,'Larus','argentatus',176824, NULL),
	(1,'HOGR','Horned Grebe',NULL,'Podiceps','auritus',174482, NULL),
	(1,'HOME','Hooded Merganser',NULL,'Lophodytes','cucullatus',175183, NULL),
	(1,'HUGO','Hudsonian Godwit',NULL,'Limosa','haemastica',176690, NULL),
	(1,'ICGU','Iceland Gull',NULL,'Larus','glaucoides',176811, NULL),
	(1,'IVGU','Ivory Gull',NULL,'Pagophila','eburnea',176851, NULL),
	(1,'JFPE','Juan Fernandez Petrel',NULL,'Pterodroma','externa externa',174575, NULL),
	(1,'KIEI','King Eider',NULL,'Somateria','spectabilis',175160, NULL),
	(1,'KILL','Killdeer',NULL,'Charadrius','vociferus',176520, NULL),
	(1,'KIRA','King Rail',NULL,'Rallus','elegans',176207, NULL),
	(1,'KUGU','Kumlien''s Gull',NULL,'Larus','glaucoides kumlieni',176813, NULL),
	(1,'LAGU','Laughing Gull',NULL,'Larus','atricilla',176837, NULL),
	(1,'LBBG','Lesser Black-backed Gull',NULL,'Larus','fuscus',176821, NULL),
	(1,'LBDO','Long-billed Dowitcher',NULL,'Limnodromus','scolopaceus',176679, NULL),
	(1,'LBHE','Little Blue Heron',NULL,'Egretta','caerulea',174827, NULL),
	(1,'LEAS','Least Storm-petrel',NULL,'Oceanodroma','microsoma',174646, NULL),
	(1,'LENO','Lesser Noddy',NULL,'Anous','tenuirostris',176943, NULL),
	(1,'LESA','Least Sandpiper',NULL,'Calidris','minutilla',176656, NULL),
	(1,'LESC','Lesser Scaup',NULL,'Aythya','affinis',175134, NULL),
	(1,'LESP','Leach''s Storm-petrel',NULL,'Oceanodroma','leucorhoa',174628, NULL),
	(1,'LETE','Least Tern',NULL,'Sterna','antillarum',176923, NULL),
	(1,'LEYE','Lesser Yellowlegs',NULL,'Tringa','flavipes',176620, NULL),
	(1,'LIGU','Little Gull',NULL,'Larus','minutus',176840, NULL),
	(1,'LISH','Little Shearwater',NULL,'Puffinus','assimilis',174559, NULL),
	(1,'LITE','Little Tern',NULL,'Sternula','albifrons',824124, NULL),
	(1,'LSGB','Lesser Snow Goose', 'Blue Phase','Chen','caerulescens',175038, NULL),
	(1,'LSGW','Lesser Snow Goose', 'White phase','Chen','caerulescens',175038, NULL),
	(1,'LTDU','Long-tailed Duck',NULL,'Clangula','hyemalis',175147, NULL),
	(1,'LTJA','Long-tailed Jaeger',NULL,'Stercorarius','longicaudus',176794, NULL),
	(1,'MABO','Masked Booby',NULL,'Sula','dactylatra',174699, NULL),
	(1,'MAFR','Magnificent Frigatebird',NULL,'Fregata','magnificens',174763, NULL),
	(1,'MAGO','Marbled Godwit',NULL,'Limosa','fedoa',176686, NULL),
	(1,'MALL','Mallard',NULL,'Anas','platyrhynchos',175063, NULL),
	(1,'MASH','Manx Shearwater',NULL,'Puffinus','puffinus',174555, NULL),
	(1,'MEGU','Mew Gull',NULL,'Larus','canus',176832, NULL),
	(1,'MOPL','Mountain Plover',NULL,'Charadrius','montanus',176522, NULL),
	(1,'NOFU','Northern Fulmar',NULL,'Fulmarus','glacialis',174536, NULL),
	(1,'NOGA','Northern Gannet',NULL,'Morus','bassanus',174712, NULL),
	(1,'NOPI','Northern Pintail',NULL,'Anas','acuta',175074,'Recognized as a monotypic by AOU (1957), Clements (2000), and Howard and Moore (2003). Subspecies Anas acuta acuta, A. a. eatoni, and A. a. ...'),
	(1,'NOTE','Unidentified Noddy Tern',NULL,NULL,NULL,NULL,NULL),
	(1,'NSHO','Northern Shoveler',NULL,'Spatula','clypeata',175096,'Monotypic. Formerly placed in the genus Anas'),
	(1,'PAJA','Parasitic Jaeger',NULL,'Stercorarius','parasiticus',176793,NULL),
	(1,'PALO','Pacific Loon',NULL,'Gavia','pacifica',174475,'Monotypic. Considered subspecies of G. arctica by AOU (1957), Peters (1979), and del Hoyo, et al. (1992)'),
	(1,'PBGR','Pied-billed Grebe',NULL,'Podilymbus','podiceps',174505,NULL),
	(1,'PECO','Pelagic Cormorant',NULL,'Phalacrocorax','pelagicus',174725,NULL),
	(1,'PELI','Unidentified Pelican','Pelecanus spp.','Pelecanus',NULL,NULL,NULL),
	(1,'PESA','Pectoral Sandpiper',NULL,'Calidris','melanotos',176653,NULL),
	(1,'PFSH','Pink-footed Shearwater',NULL,'Puffinus','creatopus',174547,NULL),
	(1,'PIPL','Piping Plover',NULL,'Charadrius','melodus',NULL,NULL),
	(1,'POJA','Pomarine Jaeger',NULL,'Stercorarius','pomarinus',176792,NULL),
	(1,'POSP','Polynesian Storm-petrel',NULL,'Nesofregetta','fuliginosa',174661,NULL),
	(1,'PUSA','Purple Sandpiper',NULL,'Calidris','maritima',176646,'Recognized as monotypic by del Hoyo et al. (1992), Clements (2000) and BNA. Howard and Moore (2003) recognizes 3 subspecies: C.m. belcheri, C.m...'),
	(1,'RAZO','Razorbill',NULL,'Alca','torda',176971,NULL),
	(1,'RBGU','Ring-billed Gull',NULL,'Larus','delawarensis',176830,NULL),
	(1,'RBME','Red-breasted Merganser',NULL,'Mergus','serrator',175187,NULL),
	(1,'RBTR','Red-billed Tropicbird',NULL,'Phaethon','aethereus',174673,NULL),
	(1,'REDH','Redhead',NULL,'Aythya','americana',175125,NULL),
	(1,'REEG','Reddish Egret',NULL,'Egretta','rufescens',174824,NULL),
	(1,'REKN','Red Knot',NULL,'Calidris','canutus',176642,NULL),
	(1,'REPH','Red Phalarope',NULL,'Phalaropus','fulicaria',554376,NULL),
	(1,'RFBO','Red-footed Booby',NULL,'Sula','sula',174707,NULL),
	(1,'RHAU','Rhinoceros Auklet',NULL,'Cerorhinca','monocerata',177023,NULL),
	(1,'RNDU','Ring-necked Duck',NULL,'Aythya','collaris',175128,NULL),
	(1,'RNGR','Red-necked Grebe',NULL,'Podiceps','grisegena',174479,NULL),
	(1,'RNPH','Red-necked Phalarope',NULL,'Phalaropus','lobatus',176735,NULL),
	(1,'ROSP','Roseate Spoonbill',NULL,'Platalea','ajaja',174941,NULL),
	(1,'ROST','Roseate Tern',NULL,'Sterna','dougallii',176891,NULL),
	(1,'ROYT','Royal Tern',NULL,'Sterna','maxima',176922,NULL),
	(1,'RTLO','Red-throated Loon',NULL,'Gavia','stellata',174474,NULL),
	(1,'RTTR','Red-tailed Tropicbird',NULL,'Phaethon','rubricauda',174679,NULL),
	(1,'RUDU','Ruddy Duck',NULL,'Oxyura','jamaicensis',175175,NULL),
	(1,'RUTU','Ruddy Turnstone',NULL,'Arenaria','interpres',176571,NULL),
	(1,'SACR','Sandhill Crane',NULL,'Grus','canadensis',176177,NULL),
	(1,'SAGU','Sabine''s Gull',NULL,'Xema','sabini',176866,NULL),
	(1,'SAND','Sanderling',NULL,'Calidris','alba',176669,'Recognized as monotypic by del Hoyo et al. (1992) and Clements (2000) and BNA. Howard and Moore recognized 2 subspecies: C.a. alba and C.a. rubida'),
	(1,'SATE','Sandwich Tern',NULL,'Sterna','sandvicensis',176927,NULL),
	(1,'SBDO','Short-billed Dowitcher',NULL,'Limnodromus','griseus',176675,NULL),
	(1,'SBGU','Slaty-backed Gull',NULL,'Larus','schistisagus',176816,NULL),
	(1,'SCAU','Unidentified Scaup','Aythya marila or A. affinis',NULL,NULL,NULL,NULL),
	(1,'SEPL','Semipalmated Plover',NULL,'Charadrius','semipalmatus',176506,NULL),
	(1,'SESA','Semipalmated Sandpiper',NULL,'Calidris','pusilla',176667,NULL),
	(1,'SHAG','Shag',NULL,'Phalacrocorax','aristotelis',174733,NULL),
	(1,'SHOR','Unidentified shorebird',NULL,NULL,NULL,NULL,NULL),
	(1,'SNEG','Snowy Egret',NULL,'Egretta','thula',174813,NULL),
	(1,'SNGO','Snow Goose',NULL,'Chen','caerulescens',175038,'Formerly placed in the genus Chen'),
	(1,'SOGU','Sooty Gull',NULL,'Larus','hemprichii',176854,NULL),
	(1,'SORA','Sora',NULL,'Porzana','carolina',176242,NULL),
	(1,'SOSA','Solitary Sandpiper',NULL,'Tringa','solitaria',176615,NULL),
	(1,'SOSH','Sooty Shearwater',NULL,'Puffinus','griseus',174553,NULL),
	(1,'SOTE','Sooty Tern',NULL,'Sterna','fuscata',176894,NULL),
	(1,'SPEI','Spectacled Eider',NULL,'Somateria','fischeri',175161,NULL),
	(1,'SPGU','Spectacled Guillemot',NULL,'Cepphus','carbo',176994,NULL),
	(1,'SPSA','Spotted Sandpiper',NULL,'Actitis','macularia',176612,NULL),
	(1,'SPSK','South Polar Skua',NULL,'Stercorarius','maccormicki',660062,NULL),
	(1,'STEI','Steller''s Eider',NULL,'Polysticta','stelleri',175153,NULL),
	(1,'STSA','Stilt Sandpiper',NULL,'Calidris','himantopus',554145,NULL),
	(1,'STSH','Short-tailed Shearwater',NULL,'Puffinus','tenuirostris',174554,NULL),
	(1,'SUSC','Surf Scoter',NULL,'Melanitta','perspicillata',175170,NULL),
	(1,'SWAN','Unidentified Swan','Olor spp.','Olor',NULL,174993,NULL),
	(1,'SWIS','Swinhoe''s Storm-petrel',NULL,'Oceanodroma','monorhis',174642,NULL),
	(1,'TAPE','Tahiti Petrel',NULL,'Pseudobulweria','rostrata',562522,NULL),
	(1,'TBMU','Thick-billed Murre',NULL,'Uria','lomvia',176978,NULL),
	(1,'THGU','Thayer''s Gull',NULL,'Larus','thayeri',176828,NULL),
	(1,'TOSH','Townsend''s Shearwater',NULL,'Puffinus','auricularis',174558,NULL),
	(1,'TRHE','Tricolored (Louisiana) Heron',NULL,'Egretta','tricolor',NULL,NULL),
	(1,'TRSP','Tristram''s Storm-Petrel',NULL,'Oceanodroma','tristrami',174641,NULL),
	(1,'TUPU','Tufted Puffin',NULL,'Fratercula','cirrhata',177032,NULL),
	(1,'TUSW','Tundra Swan',NULL,'Cygnus','columbianus',174987,NULL),
	(1,'UALB','Unidentified Albatross','Diomedeidae spp.','Diomedeidae',NULL,174513,NULL),
	(1,'UBBG','Unidentified Great or Lesser Black-backed Gull','Larus marinus/fuscus',NULL,NULL,NULL,NULL),
	(1,'UBST','Bridled or Sooty Tern','Sterna anaethetus/fuscata',NULL,NULL,NULL,NULL),
	(1,'UCAT','Common or Arctic Tern','Sterna hirundo/paradisaea',NULL,NULL,NULL,NULL),
	(1,'UCRT','Unidentified Common or Roseate Tern','Sterna hirundo/dougallii',NULL,NULL,NULL,NULL),  --includes CRTE (same meaning) which was removed
	(1,'UDAB','Unidentified dabbling duck','Anas spp.','Anas',NULL,NULL,NULL),
	(1,'UDGS','Unidentified Duck, Goose, or Swan','Anseriformes spp.',NULL,NULL,174982,NULL),
	(1,'UGOO','Unidentified Goose',NULL,NULL,NULL,NULL,NULL),
	(1,'UGUI','Unidentified Guillemot','Cepphus spp.','Cepphus',NULL,176984,NULL),
	(1,'UHGP','Unidentified Hawaiian Petrel or Galapagos Petrel','Pterodroma sandwichensis/phaeopygia',NULL,NULL,NULL,NULL),
	(1,'ULSB','Unidentified large shorebird',NULL,NULL,NULL,NULL,NULL),
	(1,'UNAL','Unidentified Alcid','Alcidae spp.',NULL,NULL,176967,NULL),
	(1,'UNBI','Unidentified Bird','Aves',NULL,NULL,174371,NULL),
	(1,'UNBO','Unidentified Booby','Sula spp.','Sula',NULL,174697,NULL),
	(1,'UNCA','Unidentified Calidris (Sandpiper, Sanderling, Dunlin, Red Knot)','Calidris spp.','Calidris',NULL,NULL,NULL),
	(1,'UNCO','Unidentified Cormorant','Phalacrocorax spp','Phalacrocorax',NULL,174714,NULL),
	(1,'UNDD','Unidentified Diving/Sea Duck','Aythya spp.','Aythya',NULL,175124,NULL),
	(1,'UNDU','Unidentified Duck','Anatidae',NULL,NULL,NULL,NULL),
	(1,'UNEG','Unidentified Egret',NULL,NULL,NULL,NULL,NULL),
	(1,'UNEI','Unidentified Eider','Somateria spp.','Somateria',NULL,175154,NULL),
	(1,'UNFR','Unidentified Frigatebird','Fregata spp.','Fregata',NULL,174762,NULL),
	(1,'UNGB','Unidentified Goldeneye/Bufflehead','Bucephala spp.','Bucephala',NULL,175140,NULL),
	(1,'UNGO','Unidentified Goldeneye','Bucephala spp.','Bucephala',NULL,175140,NULL),
	(1,'UNGR','Unidentified Grebe','Podiceps spp.','Podiceps',NULL,174478,NULL),
	(1,'UNGU','Unidentified Gull',NULL,NULL,NULL,NULL,NULL),
	(1,'UNHE','Unidentified Heron',NULL,NULL,NULL,NULL,NULL),
	(1,'UNJA','Unidentified Jaeger','Stercorarius spp.','Stercorarius',NULL,176791,NULL),
	(1,'UNLA','Unidentified large alcid (Razorbill or Murre)',NULL,NULL,NULL,NULL,NULL),
	(1,'UNLG','Unidentified Large Gull',NULL,NULL,NULL,NULL,NULL),
	(1,'UNLO','Unidentified Loon','Gavia spp.','Gavia',NULL,174468,NULL),
	(1,'UNLR','Unidentified large rail','Rallidae',NULL,NULL,176205,NULL),
	(1,'UNLS','Unidentified Large Shearwater',NULL,NULL,NULL,NULL,NULL),
	(1,'UNLT','Unidentified large Tern',NULL,NULL,NULL,NULL,NULL),
	(1,'UNME','Unidentified Merganser',NULL,NULL,NULL,NULL,NULL),
	(1,'UNMT','Unidentified medium tern',NULL,NULL,NULL,NULL,NULL),
	(1,'UNMU','Unidentified Murre','Uria spp.','Uria',NULL,176973,NULL),
	(1,'UNNH','Unidentified Night Heron',NULL,NULL,NULL,NULL,NULL),
	(1,'UNPE','Unidentified Petrel','Procellariidae',NULL,NULL,174532,NULL),
	(1,'UNPH','Unidentified Phalarope','Phalaropus spp.','Phalaropus',NULL,176733,NULL),
	(1,'UNPR','Unidentified tubenose','Procellariidae',NULL,NULL,174532,NULL),
	(1,'UNPT','Unidentified Pterodroma (petrels)','Pterodroma spp.','Pterodroma',NULL,174566,NULL),
	(1,'UNPU','Unidentified Puffin','Fratercula spp.','Fratercula',NULL,177024,NULL),
	(1,'UNSA','Unidentified small alcid (Puffin/Dovekie)','Alle alle/Fratercula arctica',NULL,NULL,NULL,NULL),
	(1,'UNSC','Unidentified Scoter','Melanitta spp.','Melanitta',NULL,175162,NULL),
	(1,'UNSG','Unidentified small gull',NULL,NULL,NULL,NULL,NULL),
	(1,'UNSH','Unidentified Shearwater','Procellariidae',NULL,NULL,174532,NULL),
	(1,'UNSK','Unidentified Skua','Stercorarius spp.','Stercorarius',NULL,176791,NULL),
	(1,'UNSP','Unidentified Storm-petrel',NULL,NULL,NULL,NULL,NULL),
	(1,'UNSS','Unidentified Small Shearwater (Audubon''s, Manx, or Little)','Puffinus lherminieri , P. puffinus, or P. assimilis','Puffinus',NULL,NULL,NULL),
	(1,'UNST','Unidentified small Tern',NULL,NULL,NULL,NULL,NULL),
	(1,'UNSU','Unidentified Sulid','Sulidae spp.',NULL,NULL,174696,NULL),
	(1,'UNTB','Unidentified Tropicbird','Phaethon spp.','Phaethon',NULL,174672,NULL),
	(1,'UNTE','Unidentified Tern',NULL,NULL,NULL,NULL,NULL),
	(1,'UNTL','Unidentified Teal',NULL,NULL,NULL,NULL,NULL),
	(1,'UNYE','Unidentified Yellowlegs','Tringa melanoleuca or T. flavipes','Tringa',NULL,NULL,NULL),
	(1,'USAN','Unidentified Sandpiper','Scolopacidae spp.',NULL,NULL,176568,NULL),
	(1,'USSB','Unidentified small shorebird',NULL,NULL,NULL,NULL,NULL),
	(1,'VIRA','Virginia Rail',NULL,'Rallus','limicola',176221,NULL),
	(1,'WBSP','White-bellied Storm-petrel',NULL,'Fregetta','grallaria',174656,NULL),
	(1,'WCTE','White-cheeked Tern',NULL,'Sterna','repressa',176914,NULL),
	(1,'WEGU','Western Gull',NULL,'Larus','occidentalis',176817,NULL),
	(1,'WESA','Western Sandpiper',NULL,'Calidris','mauri',176668,NULL),
	(1,'WFSP','White-faced Storm-petrel',NULL,'Pelagodroma','marina',174621,NULL),
	(1,'WHIB','White Ibis',NULL,'Eudocimus','albus',174930,NULL),
	(1,'WHIM','Whimbrel',NULL,'Numenius','phaeopus',176599,NULL),
	(1,'WHTE','White Tern',NULL,'Gygis','alba',176954,NULL),
	(1,'WILL','Willet',NULL,'Catoptrophorus','semipalmatus',176638,NULL),
	(1,'WIPH','Wilson''s phalarope',NULL,'Phalaropus','tricolor',176736,NULL),
	(1,'WIPL','Wilson''s Plover',NULL,'Charadrius','wilsonia',176517,NULL),
	(1,'WISN','Wilson''s Snipe',NULL,'Gallinago','delicata',726048,NULL),
	(1,'WISP','Wilson''s Storm-petrel',NULL,'Oceanites','oceanicus',174650,NULL),
	(1,'WODU','Wood Duck',NULL,'Aix','sponsa',175122,NULL),
	(1,'WRSA','White-rumped Sandpiper',NULL,'Calidris','fuscicollis',176654,NULL),
	(1,'WRSP','Wedge-rumped Storm-petrel',NULL,'Oceanodroma','tethys',174638,NULL),
	(1,'WTSH','Wedge-tailed Shearwater',NULL,'Puffinus','pacificus',174550,NULL),
	(1,'WTTR','White-tailed Tropicbird',NULL,'Phaethon','lepturus',174676,NULL),
	(1,'WWBT','White-winged Black Tern',NULL,'Chlidonias','leucopterus',176958,NULL),
	(1,'WWGU','Unidentified white winged gull (Ross''s Gull, Ivory Gull, Iceland Gull, Glaucous-winged Gull and Glaucous Gull)',NULL,'Larus',NULL,NULL,NULL),
	(1,'WWSC','White-winged Scoter',NULL,'Melanitta','fusca',175163,NULL),
	(1,'XAMU','Xantus'' Murrelet',NULL,'Synthliboramphus','hypoleucus',177011,NULL),
	(1,'YCNH','Yellow-crowned Night Heron',NULL,'Nyctanassa','violacea',174842,NULL),
	(1,'YESH','Yelkouan Shearwater',NULL,'Puffinus','yelkouan',562599,NULL),
	(1,'YLGU','Yellow-legged Gull',NULL,'Larus','cachinnans',554270,NULL),
	(1,'YNAL','Yellow-nosed Albatross',NULL,'Thalassarche','chlororhynchos',554452,NULL),

	(2,'ASDO','Atlantic Spotted Dolphin',NULL,'Stenella','frontalis',552460,NULL),
	(2,'BBWH','Blainville''s Beaked Whale',NULL,'Mesoplodon','densirstris',NULL,NULL),
 	(2,'BESE','Bearded Seal',NULL,'Erignathus','barbatus',180655,NULL),
 	(2,'BLWH','Blue Whale',NULL,'Balaenoptera','musculus',180528,NULL),
 	(2,'BODO','Bottlenose Dolphin',NULL,'Tursiops','truncatus',180426,NULL),
 	(2,'BRDO','Bridled Dolphin','Stenella attenuata/ frontalis','Stenella',NULL,NULL,NULL),
 	(2,'CBWH','Cuvier''s Beaked Whale',NULL,'Ziphius','cavirostris',180498,NULL),
 	(2,'CLDO','Clymene Dolphin',NULL,'Stenella','clymene',180435,NULL),
 	(2,'CODO','Common Dolphin',NULL,'Delphinus','delphis',180438,NULL),
 	(2,'DPSW','Unidentified Dwarf/Pygmy Sperm Whale','Kogia simus or K. breviceps','Kogia',NULL,180490,NULL),
 	(2,'DSWH','Dwarf Sperm Whale',NULL,'Kogia','sima',180492,NULL),
 	(2,'FIWH','Fin Whale',NULL,'Balaenoptera','physalus',180527,NULL),
 	(2,'FKWH','False Killer Whale',NULL,'Pseudorca','crassidens',180463,NULL),
 	(2,'FRDO','Fraser''s Dolphin',NULL,'Lagenodelphis','hosei',180440,NULL),
 	(2,'GBWH','Gervais'' Beaked Whale',NULL,'Mesoplodon','europaeus',NULL,NULL),
 	(2,'GRSE','Gray Seal',NULL,'Halichoerus','grypus',180653,NULL),
 	(2,'HAPO','Harbor Porpoise',NULL,'Phocoena','phocoena',180473,NULL),
 	(2,'HASE','Harbor Seal',NULL,'Phoca','vitulina',180649,NULL),
 	(2,'HOSE','Hooded Seal',NULL,'Cystophora','cristata',180657,NULL),
 	(2,'HRPS','Harp Seal',NULL,'Pagophilus','groenlandicus',622022,NULL),
 	(2,'HUWH','Humpback Whale',NULL,'Megaptera','novaeangliae',180530,NULL),
 	(2,'KIWH','Killer Whale',NULL,'Orcinus','orca',180469,NULL),
 	(2,'LFPW','Long-finned Pilot Whale',NULL,'Globicephala','melas',552461,NULL),
 	(2,'LSSD','Long-snouted Spinner Dolphin',NULL,'Stenella','longirostris',180429,NULL),
 	(2,'MHDO','Melon-headed Whale',NULL,'Peponocephala','electra',180459,NULL),
 	(2,'MIWH','Minke Whale',NULL,'Balaenoptera','acutorostrata',180524,NULL),
 	(2,'NABW','North Atlantic Bottle-nosed whale',NULL,'Hyperoodon','ampullatus',180504,NULL),
 	(2,'PIWH','Pilot Whale',NULL,'Globicephala',NULL,180464,NULL),
 	(2,'PKWH','Pygmy Killer Whale',NULL,'Feresa','attenuata',180460,NULL),
	(2,'PSDO','Pantropical Spotted Dolphin',NULL,'Stenella','attenuata',180430,NULL),
 	(2,'PSWH','Pygmy Sperm Whale',NULL,'Kogia','breviceps',180491,NULL),
 	(2,'RIDO','Risso''s dolphin',NULL,'Grampus','griseus',180457,NULL),
 	(2,'RISE','Ringed Seal',NULL,'Pusa','hispida',622018,NULL),
 	(2,'RIWH','Right Whale',NULL,'Eubalaena','glacialis',180537,NULL),
 	(2,'RTDO','Rough-toothed Dolphin',NULL,'Steno','bredanensis',180417,NULL),
 	(2,'SBWH','Sowerby''s Beaked Whale',NULL,'Mesoplodon','bidens',180515,NULL),
 	(2,'SEWH','Sei Whale',NULL,'Balaenoptera','borealis',180526,NULL),
 	(2,'SFWH','Short-finned Pilot Whale',NULL,'Globicephala','macrorhynchus',180466,NULL),
 	(2,'SPDO','Unidentified Spotted Dolphins (Atlantic or Pantropical)','Stenella',NULL,NULL,180428,NULL),
 	(2,'SPWH','Sperm Whale',NULL,'Physeter','macrocephalus',180489,NULL),
 	(2,'STDO','Striped Dolphin',NULL,'Stenella','coeruleoalba',180434,NULL),
 	(2,'TBWH','True''s Beaked Whale',NULL,'Mesoplodon','mirus',NULL,NULL),
 	(2,'UBKW','Unidentified Beaked Whale','Mesoplodon spp.',NULL,NULL,180506,NULL),
 	(2,'UNBW','Unidentified Baleen Whale','Mysticeti spp.',NULL,NULL,552298,NULL),
 	(2,'UNCD','Unidentified Common Dolphins','Delphinus spp.',NULL,NULL,180437,NULL),
 	(2,'UNCE','Unidentified Cetacean','Cetacea spp.',NULL,NULL,180403,NULL),
 	(2,'UNDO','Unidentified Dolphin','Delphinidae',NULL,NULL,180415,NULL),
 	(2,'UNFS','Unidentified Fin/Sei whale','Balaenoptera physalus/B. borealis','Balaenoptera',NULL,NULL,NULL),
 	(2,'UNGD','Unidentified Spotted or Bottlenose Dolphin','Stenella or Tursiops',NULL,NULL,NULL,NULL),
 	(2,'UNLD','Unidentified Lagenorhynchus dolphin','Lagenorhynchus sp.',NULL,NULL,NULL,NULL),
 	(2,'UNLW','Unidentified large whale','Cetacea spp.',NULL,NULL,180403,NULL),
 	(2,'UNMM','Unidentified Marine Mammal','Mammalia',NULL,NULL,179913,NULL),
 	(2,'UNPO','Unidentified porpoise',NULL,NULL,NULL,NULL,NULL),
 	(2,'UNRO','Unidentified Rorqual','Balaenopteridae spp.',NULL,NULL,180522,NULL),
 	(2,'UNSE','Unidentified Seal','Phocidae',NULL,NULL,180640,NULL), -- includes UNI,UNPD for unidentified pinniped which was removed
 	(2,'UNSW','Unidentified small whale','Cetacea spp.',NULL,NULL,180403,NULL),
 	(2,'UNTW','Unidentified Toothed Whales','Odontoceti spp.',NULL,NULL,180404,NULL),
 	(2,'UNWH','Unidentified Whale','Cetacea spp.',NULL,NULL,180403,NULL),
	(2,'UNZI','Unidentified Ziphiid (beaked whale)','Ziphiidae',NULL,NULL,180493,NULL),
 	(2,'UTSE','Unidentified True Seal','Phocidae spp.',NULL,NULL,180640,NULL),
 	(2,'WALR','Walrus',NULL,'Odobenus','rosmarus',180639,NULL),
 	(2,'WBDO','White-beaked Dolphin',NULL,'Lagenorhynchus','albirostris',180442,NULL),
	(2,'WIMA','West Indian Manatee',NULL,'Trichechus','manatus',180684,NULL),
	(2,'WSDO','Atlantic White-sided Dolphin',NULL,'Lagenorhynchus','acutus',180443,NULL),

	(3,'GRTU','Green Turtle',NULL,'Chelonia','mydas',173833,NULL),
	(3,'HATU','Hawksbill Turtle',NULL,'Eretmochelys','imbricata',173837,NULL),
	(3,'KRST','Kemp''s Ridley Sea Turtle',NULL,'Lepidochelys','kempii',551770,NULL),
	(3,'LETU','Leatherback Turtle',NULL,'Dermochelys','coriacea',173843,NULL),
	(3,'LOTU','Loggerhead Turtle',NULL,'Caretta','caretta',173830,NULL),
	(3,'SMTU','Unidentified Small turtle - Loggerhead, Green, Hawksbill, or Kemp''s Ridley',NULL,NULL,NULL,NULL,NULL),
	(3,'TURT','Unidentified Sea Turtle',NULL,NULL,NULL,NULL,NULL),
	(3,'UNCH','Unidentified Cheloniidae species (Green Sea Turtle, Hawksbill Sea Turtle, and Flatback Sea Turtle)','Cheloniidae spp.',NULL,NULL,NULL,NULL),

	(4,'ALTU','Albacore Tuna',NULL,'Thunnus','alalunga',172419,NULL),
	(4,'BASH','Basking Shark',NULL,'Cetorhinus','maximus',159907,NULL),
	(4,'BFTU','Atlantic Bluefin Tuna',NULL,'Thunnus','thynnus',172421,NULL),
	(4,'BIFI','Billfishes','Istiophoridae spp.',NULL,NULL,172486,NULL),
	(4,'BLAT','Blackfin Tuna',NULL,'Thunnus','atlanticus',172427,NULL),
	(4,'BLMA','Blue Marlin',NULL,'Makaira','nigricans',172491,NULL),
	(4,'BLSH','Blue Shark',NULL,'Prionace','glauca',160424,NULL),
	(4,'BLST','Bluntnose Stingray',NULL,'Dasyatis','say',160954,NULL),
	(4,'BLUE','Bluefish',NULL,'Pomatomus','saltatrix',168559,NULL),
	(4,'BONI','Bonito',NULL,'Scombridae','spp.',172398,NULL),
	(4,'COBI','Cobia',NULL,'Rachycentron','canadum',168566,NULL),
	(4,'CNRA','Cownose Ray',NULL,'Rhinoptera','bonasus',160985,NULL),
	(4,'DUSH','Dusky Shark',NULL,'Carcharhinus','obscurus',160268,NULL),
	(4,'FAAL','False Albacore',NULL,'Euthynnus','alletteratus',172402,NULL),
	(4,'FISH','Unidentified fish','Osteichthyes',NULL,NULL,161030,NULL),
	(4,'GHSH','Great Hammerhead Shark',NULL,'Sphyrna','mokarran',160515,NULL),
	(4,'GOMR','Giant Oceanic Manta Ray',NULL,'Manta','birostris',160992,NULL),
	(4,'GWSH','Great White Shark',NULL,'Carcharodon','carcharias',159903,NULL),
	(4,'HASH','Hammerhead shark','Sphyrnidae spp.',NULL,NULL,160497,NULL),
	(4,'KIMA','King Mackerel',NULL,'Scomberomorus','cavalla',172435,NULL),
	(4,'MAKO','Unidentified Long-finned/Short-finned Mako Shark','Isurus spp.',NULL,NULL,159923,NULL),
	(4,'MAMA','Dolphin fish (Mahi-Mahi)',NULL,'Coryphaena','hippurus',168791,NULL),
	(4,'MARA','Unidentified Manta Ray','Mobulidae',NULL,NULL,160990,NULL),
	(4,'MOLA','Ocean Sunfish (Mola)',NULL,'Mola','mola',173414,NULL),
	(4,'OWTS','Oceanic Whitetip Shark (aka. Brown shark, brown Milbert''s sand bar shark, nigano shark, silvertip shark)',NULL,'Carcharhinus','longimanus',160330,NULL),
	(4,'SAFI','Sargassumfish',NULL,'Histrio','histrio',164520,NULL),
	(4,'SAIL','Sailfish',NULL,'Istiophorus','platypterus',172488,NULL),
	(4,'SCHA','Scalloped Hammerhead Shark',NULL,'Sphyrna','lewini',160508,NULL),
	(4,'SHAR','Unidentified shark','Elasmobranchii spp.',NULL,NULL,159786,NULL),
	(4,'SHSH','Smooth Hammerhead shark',NULL,'Sphyrna','zygaena',160505,NULL),
	(4,'SHSU','Sharptail Sunfish',NULL,'Masturus','lanceolatus',173419,NULL), 
	(4,'SKTU','Skipjack Tuna',NULL,'Katsuwonus','pelamis',172401,NULL),
	(4,'SMSH','Shortfin Mako Shark',NULL,'Isurus','oxyrinchus',159924,NULL),
	(4,'SPDF','Spiny dogfish (Spurdog, Grayfish, piked dogfish)',NULL,'Squalus','acanthias',160617,NULL),
	(4,'SPMA','Spanish mackerels','Scomberomorus spp.',NULL,NULL,172434,NULL),
	(4,'SWFI','Unidentified Swordfish spp.','Xiphiidae spp.',NULL,NULL,172480,NULL),
	(4,'THHE','Thread Herrings','Opisthonema spp.',NULL,NULL,161747,NULL),
	(4,'TISH','Tiger shark',NULL,'Galeocerdo','cuvier',160189,NULL),
	(4,'TUNA','Unidentified tuna','Scombridae',NULL,NULL,172398,NULL),
	(4,'UFFI','Unidentified flying fish','Exocoetidae spp.',NULL,NULL,165431,NULL),
	(4,'UNEL','Unidentified elasmobranch (Shark, Ray, Skate)','Elasmobranch',NULL,NULL,NULL,NULL),
	(4,'UNLF','Unidentified large fish','Osteichthyes spp.',NULL,NULL,161030,NULL),
	(4,'UNRA','Unidentified ray','Rajiformes spp.',NULL,NULL,160806,NULL),
	(4,'UNSF','Unidentified small fish','Osteichthyes spp.',NULL,NULL,161030,NULL),
	(4,'UNSR','Unidentified stringray','Dasyatidae spp.',NULL,NULL,NULL,NULL),
	(4,'UNTS','Unidentified thresher shark',NULL,NULL,NULL,NULL,NULL),
	(4,'WAHO','Wahoo',NULL,'Acanthocybium','solandri',172451,NULL),
	(4,'WHMA','White Marlin',NULL,'Kajikia','albida',768126,NULL),
	(4,'WHSH','Whale shark',NULL,'Rhincodon','typus',159857,NULL),
	(4,'YETU','Yellowfin Tuna',NULL,'Thunnus','albacares',172423,NULL),
	(4,'BAIT','bait ball',NULL,NULL,NULL,NULL,NULL),
	(4,'CAJE','Cannonball Jelly',NULL,'Stomolophus','meleagris',51926,NULL),
	(4,'HOCR','Atlantic Horseshoe Crab',NULL,'Limulus','polyphemus',82703,NULL),
	(4,'MOON','Moon Jellyfish',NULL,'Aurelia','aurita',51701,NULL),
	(4,'PMOW','Portuguese Man o'' War',NULL,'Physalia','physalis',719181,NULL),
	(4,'UNJE','Unidentified jellyfish','Scyphozoa spp.',NULL,NULL,51483,NULL),

	(5,'ALGA','Algal bloom',NULL,NULL,NULL,NULL,NULL),
	(5,'ANTE','Antennae',NULL,NULL,NULL,NULL,NULL),
	(5,'BALN','balloon',NULL,NULL,NULL,NULL,NULL),
	(5,'BUOY','buoy',NULL,NULL,NULL,NULL,NULL),
	(5,'CHAN','Change in personnel, station, transect, etc.',NULL,NULL,NULL,NULL,NULL),
	(5,'CLSU','Cloudless Sulphur',NULL,'Phoebis','sennae',777750,NULL),
	(5,'ERRO','error',NULL,NULL,NULL,NULL,NULL),
	(5,'FGGI','fixed gear-gill net',NULL,NULL,NULL,NULL,NULL),
	(5,'FGLO','fixed gear-lobster',NULL,NULL,NULL,NULL,NULL),
	(5,'FGUN','fixed gear-unidentified',NULL,NULL,NULL,NULL,NULL),
	(5,'FIGE','fishing gear',NULL,NULL,NULL,NULL,NULL),
	(5,'FLJE','flotsam and jetsam',NULL,NULL,NULL,NULL,NULL),
	(5,'FUEL','oil/fuel',NULL,NULL,NULL,NULL,NULL),
	(5,'ICE','ice',NULL,NULL,NULL,NULL,NULL),
	--(5,'KRILL','Unidentified krill',NULL,NULL),--change to ZOOP
	(5,'LABA','Latex balloon',NULL,NULL,NULL,NULL,NULL),
	(5,'LINE','rope/line',NULL,NULL,NULL,NULL,NULL),
	(5,'MACR','macroalgae',NULL,NULL,NULL,NULL,NULL),
	(5,'MYBA','Mylar balloon',NULL,NULL,NULL,NULL,NULL),
	--(5,'NONE','none',NULL,NULL),--change to unkn
	(5,'OCFR','ocean front',NULL,NULL,NULL,NULL,NULL),
	(5,'ORSU','Orange Sulphur',NULL,'Colias','eurytheme',188528,NULL),
	(5,'PLAS','plastic',NULL,NULL,NULL,NULL,NULL),
	(5,'POBE','Polar Bear',NULL,'Ursus','maritimus',180542,NULL),
	(5,'PONY','Pony',NULL,NULL,NULL,NULL,NULL),
	(5,'RCKW','rockweed',NULL,'Pilea','microphylla',19133,NULL),
	(5,'REBA','Red Bat',NULL,'Lasiurus','borealis',180016,NULL),
	(5,'SARG','Sargassum',NULL,NULL,NULL,11389,NULL),
	(5,'SPEN','Salmon Pens',NULL,NULL,NULL,NULL,NULL),
	(5,'TOWR','Tower',NULL,NULL,NULL,NULL,NULL),
	--(5,'TRAN','transect point',NULL,NULL),--remove from observation table
	(5,'UBAT','Unidentified Bat',NULL,NULL,NULL,NULL,NULL),
	(5,'UFOB','Unidentified flying object (animal-origin)',NULL,NULL,NULL,NULL,NULL),
	--(5,'UNCT','??',NULL,NULL),--change to unkn
	(5,'UNKN','unknown',NULL,NULL,NULL,NULL,NULL),
	(5,'ZOOP','zooplankton',NULL,NULL,NULL,NULL,NULL),

	(6,'BDDR','Blue Dasher Dragonfly',NULL,'Pachydiplax','longipennis',101799,NULL),
	--(6,'BLST','Black Swallowtail','Papilio polyxenes ',188545),--change to BSTB
	(6,'BSTB','Black Swallowtail Butterfly',NULL,'Papilio','polyxenes',188543,NULL),
	(6,'BUMB','Unidentified Bee',NULL,NULL,NULL,NULL,NULL),
	(6,'DRAG','dragonfly spp.',NULL,NULL,NULL,NULL,NULL),
	(6,'GISW','Giant Swallowtail Butterfly',NULL,'Papilio','cresphontes',NULL,NULL),
	(6,'GRDA','Green Darner',NULL,'Anax','junius',101598,NULL),
	(6,'MONA','Monarch Butterfly',NULL,'Danaus','plexippus',117273,NULL),
	(6,'PLBU','Painted Lady Butterfly',NULL,'Vanessa','cardui',188601,NULL),
	(6,'SUBU','Sulfur Butterfly spp.','Coliadinae spp.',NULL,NULL,694016,NULL),
	(6,'SWDA','Swamp Darner',NULL,'Epiaeschna','heros',101638,NULL),
	(6,'UBUT','Unidentified butterfly',NULL,NULL,NULL,NULL,NULL),
	(6,'UNMO','Unidentified Moth',NULL,NULL,NULL,NULL,NULL),
	(6,'WAGL','Wandering Glider',NULL,'Pantala','flavescens',101801,NULL),

	(7,'BOAC','Boat-Aircraft carrier',NULL,NULL,NULL,NULL,NULL),
	(7,'BOAT','Boat-Unidentified',NULL,NULL,NULL,NULL,NULL),
	(7,'BOBA','Boat-Barge/barge and tug',NULL,NULL,NULL,NULL,NULL),
	(7,'BOCA','Boat-Cargo',NULL,NULL,NULL,NULL,NULL),
	(7,'BOCF','Boat-Commercial fishing',NULL,NULL,NULL,NULL,NULL),
	(7,'BOCG','Boat-Coast Guard',NULL,NULL,NULL,NULL,NULL),
	(7,'BOCR','Boat-Cruise',NULL,NULL,NULL,NULL,NULL),
	(7,'BOCS','Boat-Container ship',NULL,NULL,NULL,NULL,NULL),
	(7,'BOFE','Boat-Ferry',NULL,NULL,NULL,NULL,NULL),
	(7,'BOFI','Boat-Fishing',NULL,NULL,NULL,NULL,NULL),
	(7,'BOLO','Boat-Lobster',NULL,NULL,NULL,NULL,NULL),
	(7,'BOME','Boat-Merchant',NULL,NULL,NULL,NULL,NULL),
	(7,'BONA','Boat-Navy',NULL,NULL,NULL,NULL,NULL),
	(7,'BOPL','Boat-Pleasure',NULL,NULL,NULL,NULL,NULL),
	(7,'BOPS','Boat-Purseiner',NULL,NULL,NULL,NULL,NULL),
	(7,'BORF','Boat-Recreational fishing',NULL,NULL,NULL,NULL,NULL),
	(7,'BORV','Boat-Research vessel',NULL,NULL,NULL,NULL,NULL),
	(7,'BOSA','Boat-Sail',NULL,NULL,NULL,NULL,NULL),
	(7,'BOSU','Boat-Submarine',NULL,NULL,NULL,NULL,NULL),
	(7,'BOTA','Boat-Tanker',NULL,NULL,NULL,NULL,NULL),
	(7,'BOTD','Boat-Trawler/dragger',NULL,NULL,NULL,NULL,NULL),
	(7,'BOTU','Boat-Tug',NULL,NULL,NULL,NULL,NULL),
	(7,'BOWW','Boat-Whale watch',NULL,NULL,NULL,NULL,NULL),
	(7,'BOYA','Boat-Yacht',NULL,NULL,NULL,NULL,NULL),
	
	(8,'AMKE','American Kestrel',NULL,'Falco','sparverius',175622, NULL),
	(8,'AMPI','American Pipit',NULL,'Anthus','rubescens',554127, NULL),
	(8,'AMRE','American Redstart',NULL,'Setophaga','ruticilla',178979,NULL),
	(8,'AMGO','American Goldfinch',NULL,'Carduelis','tristis',179236,NULL),
	(8,'AMRO','American Robin',NULL,'Turdus','migratorius',179759,NULL),
	(8,'AMCR','American Crow',NULL,'Corvus','brachyrhynchos',179731,NULL),
	(8,'ATSP','American Tree Sparrow',NULL,'Spizella','arborea',179432,NULL),
	(8,'BAEA','Bald Eagle',NULL,'Haliaeetus','leucocephalus',175420,NULL),
	(8,'BANO','Barn Owl',NULL,'Tyto','alba',177851,NULL),
	(8,'BANS','Bank Swallow',NULL,'Riparia','riparia',178436,NULL),
	(8,'BAOR','Baltimore Oriole',NULL,'Icterus','galbula',179083,NULL),
	(8,'BAOW','Barred Owl',NULL,'Strix','varia',177921,NULL),
	(8,'BARS','Barn Swallow',NULL,'Hirundo','rustica',178448,NULL),
	(8,'BAWW','Black-and-white Warbler',NULL,'Mniotilta','varia',178844,NULL),
	(8,'BBCU','Black-billed Cuckoo',NULL,'Coccyzus','erythropthalmus',177834, NULL),
	(8,'BBWO','Black-backed Woodpecker',NULL,'Picoides','arcticus',178250,NULL),
	(8,'BCCH','Black-capped Chickadee',NULL,'Poecile','atricapillus',554382,NULL),
	(8,'BEKI','Belted Kingfisher',NULL,'Megaceryle','alcyon',178106, NULL),
	(8,'BGGN','Blue-gray Gnatcatcher',NULL,'Polioptila','caerulea',179853,NULL),
	(8,'BHCO','Brown-headed Cowbird',NULL,'Molothrus','ater',179112,NULL),
	(8,'BLBW','Blackburnian Warbler',NULL,'Dendroica','fusca',178904,NULL),
	(8,'BLJA','Blue Jay',NULL,'Cyanocitta','cristata',179680,NULL),
	(8,'BLPW','Blackpoll Warbler',NULL,'Dendroica','striata',178913,NULL),
	(8,'BLVU','Black Vulture',NULL,'Coragyps','atratus',175272,NULL),
	(8,'BOBO','Bobolink',NULL,'Dolichonyx','oryzivorus',179032, NULL),
	(8,'BOCH','Boreal Chickadee',NULL,'Poecile','hudsonica',554386,NULL),
	(8,'BOWA','Bohemian Waxwing',NULL,'Bombycilla','garrulus',178529, NULL),
	(8,'BRBL','Brewer''s Blackbird',NULL,'Euphagus','cyanocephalus',179094, NULL),
	(8,'BRCR','Brown Creeper',NULL,'Certhia','americana',178803, NULL),
	(8,'BRTH','Brown Thrasher',NULL,'Toxostoma','rufum',178627, NULL),
	(8,'BTBW','Black-throated Blue Warbler',NULL,'Dendroica','caerulescens',178888,NULL),
	(8,'BTGR','Boat-tailed Grackle',NULL,'Quiscalus','major',179108,NULL),
	(8,'BTNW','Black-throated Green Warbler',NULL,'Dendroica','virens',178898, NULL),
	(8,'BUTE','Unidentified Buteo','Buteo',NULL,NULL,175349, NULL),
	(8,'BWWA','Blue-winged Warbler',NULL,'Vermivora','pinus',178853,NULL),
	(8,'CACH','Carolina Chickadee',NULL,'Poecile','carolinensis',554383, NULL),
	(8,'CARW','Carolina Wren',NULL,'Thryothorus','ludovicianus',178581,NULL),
	(8,'CASW','Cave Swallow',NULL,'Petrochelidon','fulva',178460,NULL),
	(8,'CAWA','Canada Warbler',NULL,'Cardellina','canadensis',950079,NULL),
	(8,'CEDW','Cedar Waxwing',NULL,'Bombycilla','cedrorum',178532,NULL),
	(8,'CHIC','Unidentified Chickadee',NULL,NULL,NULL,NULL,NULL),
	(8,'CHSP','Chipping Sparrow',NULL,'Spizella','passerina',179435,NULL),
	(8,'CHSW','Chimney Swift',NULL,'Chaetura','pelagica',178001, NULL),
	(8,'CLSW','Cliff Swallow',NULL,'Petrochelidon','pyrrhonota',178455, NULL),
	(8,'CMWA','Cape May Warbler',NULL,'Dendroica','tigrina',178887,NULL),
	(8,'COGR','Common Grackle',NULL,'Quiscalus','quiscula',179104,NULL),
	(8,'COHA','Cooper''s Hawk',NULL,'Accipiter','cooperii',175309,NULL),
	(8,'CONI','Common Nighthawk',NULL,'Chordeiles','minor',177979,NULL),
	(8,'CORA','Common Raven',NULL,'Corvus','corax',179725,NULL),
	(8,'CORE','Common Redpoll',NULL,'Carduelis','flammea',179230,NULL),
	(8,'COYE','Common Yellowthroat',NULL,'Geothlypis','trichas',178944, NULL),
	(8,'DEJU','Dark-eyed Junco',NULL,'Junco','hyemalis',179410, NULL),
	(8,'DOWO','Downy Woodpecker',NULL,'Picoides','pubescens',178259,NULL),
	(8,'EABL','Eastern Bluebird',NULL,'Sialia','sialis',179801,NULL),
	(8,'EAKI','Eastern Kingbird',NULL,'Tyrannus','tyrannus',178279, NULL),
	(8,'EAME','Eastern Meadowlark',NULL,'Sturnella','magna',179034, NULL),
	(8,'EAPH','Eastern Phoebe',NULL,'Sayornis','phoebe',178329, NULL),
	(8,'EASO','Eastern Screech-Owl',NULL,'Megascops','asio',686658, NULL),
	(8,'EATO','Eastern Towhee',NULL,'Pipilo','erythrophthalmus',179276, NULL),
	(8,'EAWP','Eastern Wood-Pewee',NULL,'Contopus','virens',178359,NULL),
	(8,'EUCD','Eurasian Collared-Dove',NULL,'Streptopelia','decaocto',177139, NULL),
	(8,'EUST','European Starling',NULL,'Sturnus','vulgaris',179637,NULL),
	(8,'EVGR','Evening Grosbeak',NULL,'Coccothraustes','vespertinus',179173, NULL),
	(8,'FICR','Fish Crow',NULL,'Corvus','ossifragus',179737, NULL),
	(8,'FALC','Unidentified falcon','Falco spp.',NULL,NULL,175598,NULL),
	(8,'FISP','Field Sparrow',NULL,'Spizella','pusilla',179443,NULL),
	(8,'FOSP','Fox Sparrow',NULL,'Passerella','iliaca',179464,NULL),
	(8,'GCFC','Great Crested Flycatcher',NULL,'Myiarchus','crinitus',178309,NULL),
	(8,'GCKI','Golden-crowned Kinglet',NULL,'Regulus','satrapa',179865, NULL),
	(8,'GHOW','Great Horned Owl',NULL,'Bubo','virginianus',177884,NULL),
	(8,'GRCA','Gray Catbird',NULL,'Dumetella','carolinensis',178625,NULL),
	(8,'GRAJ','Gray Jay',NULL,'Perisoreus','canadensis',179667, NULL),
	(8,'GRAK','Gray Kingbird',NULL,'Tyrannus','dominicensis',178280, NULL),
	(8,'GRSP','Grasshopper Sparrow',NULL,'Ammodramus','savannarum',179333,NULL),
	(8,'HAWK','Unidentified hawk',NULL,NULL,NULL,NULL,NULL),
	(8,'HAWO','Hairy Woodpecker',NULL,'Picoides','villosus',178262,NULL),
	(8,'HETH','Hermit Thrush',NULL,'Catharus','guttatus',179779,NULL),
	(8,'HOFI','House Finch',NULL,'Carpodacus','mexicanus',179191,NULL),
	(8,'HOLA','Horned Lark',NULL,'Eremophila','alpestris',554256,NULL),
	(8,'HORE','Hoary Redpoll',NULL,'Carduelis','hornemanni',179231,NULL),
	(8,'HOSP','House Sparrow',NULL,'Passer','domesticus',179628,NULL),
	(8,'HOWA','Hooded Warbler',NULL,'Wilsonia','citrinis',178972,NULL),
	(8,'HOWR','House Wren',NULL,'Troglodytes','aedon',178541,NULL),
	(8,'INBU','Indigo Bunting',NULL,'Passerina','cyanea',179150, NULL),
	(8,'JUNC','Unidentified junco',NULL,NULL,NULL,179409, NULL),
	(8,'LALO','Lapland Longspur',NULL,'Calcarius','lapponicus',179526, NULL),
	(8,'LISP','Lincoln''s Sparrow',NULL,'Melospiza','lincolnii',179484, NULL),
	(8,'LEOW','Long-eared Owl',NULL,'Asio','otus',177932,NULL),
	(8,'LONG','Unidentified Longspur','Calcarius spp.','Calcarius',NULL,179524, NULL),
	(8,'LOSH','Loggerhead Shrike',NULL,'Lanius','ludovicianus',178515, NULL),
	(8,'MAWA','Magnolia Warbler',NULL,'Dendroica','magnolia',178886,NULL),
	(8,'MAWR','Marsh Wren',NULL,'Cistothorus','palustris',178608,NULL),
	(8,'MEAD','Unidentified Meadowlark','Sturnella spp.','Sturnella',NULL,179033, NULL),
	(8,'MERL','Merlin',NULL,'Falco','columbarius',175613, NULL),
	(8,'MODO','Mourning Dove',NULL,'Zenaida','macroura',177125,NULL),
	(8,'MOWA','Mourning Warbler',NULL,'Oporornis','philadelphia',178939,NULL),
	(8,'MUSW','Mute Swan',NULL,'Cygnus','Olor',174985,NULL),
	(8,'MYWA','Myrtle Warbler',NULL,'Dendroica','c. coronata',178892,NULL),
	(8,'NAWA','Nashville Warbler',NULL,'Vermivora','ruficapilla',178861,NULL),
	(8,'NHOW','Northern Hawk Owl',NULL,'Surnia','ulula',177898,NULL),
	(8,'NOBO','Northern Bobwhite',NULL,'Colinus','virginianus',175863, NULL),
	(8,'NOCA','Northern Cardinal',NULL,'Cardinalis','cardinalis',179124,NULL),
	(8,'NOFL','Northern Flicker',NULL,'Colaptes','auratus',178154, NULL),
	(8,'NOGO','Northern Goshawk',NULL,'Accipiter','gentilis',175300,NULL),
	(8,'NOHA','Northern Harrier',NULL,'Circus','cyaneus',175430,NULL),
	(8,'NOMO','Northern Mockingbird',NULL,'Mimus','polyglottos',178620,NULL),
	(8,'NOPA','Northern Parula',NULL,'Parula','americana',178868,NULL),
	(8,'NOWA','Northern Waterthrush',NULL,'Seiurus','noveboracensis',178931,NULL),
	(8,'NRWS','Northern Rough-winged Swallow',NULL,'Stelgidopteryx','serripennis',178443,NULL),
	(8,'NSHR','Northern Shrike',NULL,'Lanius','borealis',178511,'Formerly considered conspecific with Lanius excubitor'),
	(8,'NSTS','Nelson''s Sharp-tailed Sparrow',NULL,'Ammodramus','nelsoni',554031,NULL),
	(8,'NSWO','Northern Saw-whet Owl',NULL,'Aegolius','acadicus',177942,NULL),
	(8,'OCWA','Orange-crowned Warbler',NULL,'Vermivora','celata',178856,NULL),
	(8,'OSPR','Osprey',NULL,'Pandion','haliaetus',175590,NULL),
	(8,'OROR','Orchard Oriole',NULL,'Icterus','spurius',179064,NULL),
	(8,'OVEN','Ovenbird',NULL,'Seiurus','aurocapillus',178927,NULL),
	(8,'PAWA','Palm Warbler',NULL,'Dendroica','palmarum',178921,NULL),
	(8,'PEFA','Peregrine Falcon',NULL,'Falco','peregrinus',175604,NULL),
	(8,'PHVI','Philadelphia Vireo',NULL,'Vireo','philadelphicus',NULL,NULL),
	(8,'PIGR','Pine Grosbeak',NULL,'Pinicola','enucleator',179205,NULL),
	(8,'PISI','Pine Siskin',NULL,'Carduelis','pinus',179233,NULL),
	(8,'PIWA','Pine Warbler',NULL,'Dendroica','pinus',178914,NULL),
	(8,'PIWO','Pileated Woodpecker',NULL,'Dryocopus','pileatus',178166,NULL),
	(8,'PRAW','Prairie Warbler',NULL,'Dendroica','discolor',178918,NULL),
	(8,'PROW','Prothonotary Warbler',NULL,'Protonotaria','citrea',178846,NULL),
	(8,'PUFI','Purple Finch',NULL,'Carpodacus','purpureus',179186,NULL),
	(8,'PUMA','Purple Martin',NULL,'Progne','subis',178464,NULL),
	(8,'RBGR','Rose-breasted Grosbeak',NULL,'Pheucticus','ludovicianus',179139,NULL),
	(8,'RBNU','Red-breasted Nuthatch',NULL,'Sitta','canadensis',178784,NULL),
	(8,'RBWO','Red-bellied Woodpecker',NULL,'Melanerpes','carolinus',178195,NULL),
	(8,'RCKI','Ruby-crowned Kinglet',NULL,'Regulus','calendula',179870,NULL),
	(8,'RECR','Red Crossbill',NULL,'Loxia','curvirostra',179259,NULL),
	(8,'REDP','Common or Hoary Redpoll','Carduelis flammea/hornemanni',NULL,NULL,NULL,NULL),
	(8,'REVI','Red-eyed Vireo',NULL,'Vireo','olivaceous',179021,NULL),
	(8,'RHWO','Red-headed Woodpecker',NULL,'Melanerpes','erythrocephalus',178186,NULL),
	(8,'RITD','Ringed Turtle-Dove',NULL,'Streptopelia','risoria',177136,NULL),
	(8,'RLHA','Rough-legged Hawk',NULL,'Buteo','lagopus',175373,NULL),
	(8,'RNEP','Ring-necked Pheasant',NULL,'Phasianus','colchicus',175905,NULL),
	(8,'ROPI','Rock Pigeon',NULL,'Columba','livia',177071,NULL),
	(8,'ROSW','Rough-Winged Swallow',NULL,'Stelgidopteryx',NULL,178439,NULL),
	(8,'RSHA','Red-shouldered Hawk',NULL,'Buteo','lineatus',175359,NULL),
	(8,'RTHA','Red-tailed Hawk',NULL,'Buteo','jamaicensis',175350,NULL),
	(8,'RTHU','Ruby-throated Hummingbird',NULL,'Archilochus','colubris',178032,NULL),
	(8,'RUBL','Rusty Blackbird',NULL,'Euphagus','carolinus',179091,NULL),
	(8,'RUGR','Ruffed Grouse',NULL,'Bonasa','umbellus',175790,NULL),
	(8,'RWBL','Red-winged Blackbird',NULL,'Agelaius','phoeniceus',179045,NULL),
	(8,'SAVS','Savannah Sparrow',NULL,'Passerculus','sandwichensis',179314,NULL),
	--(8,'SCRE','Eastern Screech Owl',NULL,'Megascops','asio',686658,NULL), -- change all records to EASO
	(8,'SCTA','Scarlet Tanager',NULL,'Piranga','olivacea',179883,NULL),
	(8,'SEOW','Short-eared Owl',NULL,'Asio','flammeus',177935,NULL),
	(8,'SEWR','Sedge Wren',NULL,'Cistothorus','platensis',178605,NULL),
	(8,'SNBU','Snow Bunting',NULL,'Plectrophenax','nivalis',179532,NULL),
	(8,'SNOW','Snowy Owl',NULL,'Bubo','scandiacus',686683,NULL),
	(8,'SOSP','Song Sparrow',NULL,'Melospiza','melodia',179492,NULL),
	(8,'SPAR','Unidentified sparrow','Emberizidae',NULL,NULL,178838,NULL),
	(8,'SPGR','Spruce Grouse',NULL,'Falcipennis','canadensis',553896,NULL),
	(8,'SPPI','Sprague''s Pipit',NULL,'Anthus','spragueii',178499,NULL),
	(8,'SSHA','Sharp-shinned Hawk',NULL,'Accipiter','striatus',175304,NULL),
	(8,'SWAL','Unidentified Swallow','Hirundinidae',NULL,NULL,178423,NULL),
	(8,'TEWA','Tennessee Warbler',NULL,'Vermivora','peregrina',178855,NULL),
	(8,'TRES','Tree Swallow',NULL,'Tachycineta','bicolor',178431,NULL),
	(8,'SWSP','Swamp Sparrow',NULL,'Melospiza','georgiana',179488,NULL),
	(8,'TUTI','Tufted Titmouse',NULL,'Baeolophus','bicolor',554138,NULL),
	(8,'TUVU','Turkey Vulture',NULL,'Cathartes','aura',175265,NULL),
	(8,'UAHA','Unidentified Accipiter Hawk','Accipiter spp.','Accipiter',NULL,175299,NULL),
	(8,'UNAM','Unidentified Seaside or Sharptailed Sparrow','Ammodramus spp.','Ammodramus',NULL,179332,NULL),
	(8,'UNBL','Unidentified Blackbird','Icteridae spp.',NULL,NULL,179030,NULL),
	(8,'UNCR','Unidentified Crow','Corvus spp.','Corvus',NULL,179724,NULL),
	(8,'UNFI','Unidentified Finch','Carduelis spp.','Carduelis',NULL,179225,NULL),
	(8,'UNFL','Unidentified Flycatcher','Empidonax spp.','Empidonax',NULL,178337,NULL),
	(8,'UNHU','Unidentified Hummingbird','Trochilidae',NULL,NULL,NULL,NULL),
	(8,'UNNI','Unidentified Nighthawk',NULL,NULL,NULL,NULL,NULL),
	(8,'UNOR','Unidentified Oriole','Icterus spp.','Icterus',NULL,179063,NULL),
	(8,'UNOW','Unidentified Owl','Strigidae',NULL,NULL,177854,NULL),
	(8,'UNPA','Unidentified Passerine (perching birds, songbirds)',NULL,NULL,NULL,NULL,NULL),
	(8,'UNRP','Unidentified Raptor/ bird of prey',NULL,NULL,NULL,NULL,NULL),
	(8,'UNTA','Unidentified Tanager',NULL,NULL,NULL,NULL,NULL),
	(8,'UNTH','Unidentified Thrush','Turdidae spp.',NULL,NULL,179751,NULL),
	(8,'UNVI','Unidentified Vireo',NULL,NULL,NULL,NULL,NULL),
	(8,'UNWA','Unidentified Warbler',NULL,NULL,NULL,NULL,NULL),
	(8,'USAC','Unidentified small Accipiter',NULL,NULL,NULL,NULL,NULL),
	(8,'USOW','Unidentified small owl',NULL,NULL,NULL,NULL,NULL),
	(8,'VERM','Unidentified Vermivora','Vermivora',NULL,NULL,178851,NULL),
	(8,'VESP','Vesper Sparrow',NULL,'Pooecetes','gramineus',179366,NULL),
	(8,'WBNU','White-breasted Nuthatch',NULL,'Sitta','carolinensis',178775,NULL),
	(8,'WAPI','Water Pipit',NULL,'Anthus','spinoletta',178489,NULL),
	(8,'WCSP','White-crowned Sparrow',NULL,'Zonotrichia','leucophrys',179455,NULL),
	(8,'WEVI','White-eyed Vireo',NULL,'Vireo','griseus',178991,NULL),
	(8,'WITU','Wild Turkey',NULL,'Meleagris','gallopavo',176136,NULL),
	(8,'WIWA','Wilson''s Warbler',NULL,'Wilsonia','pusilla',178973,NULL),
	(8,'WIWR','Winter Wren',NULL,'Troglodytes','troglodytes',178547,NULL),
	(8,'WOTH','Wood Thrush',NULL,'Hylocichla','mustelina',179777,NULL),
	(8,'WTSP','White-throated Sparrow',NULL,'Zonotrichia','albicollis',179462,NULL),
	(8,'WWCR','White-winged Crossbill',NULL,'Loxia','leucoptera',179268,NULL),
	(8,'WWDO','White-winged Dove',NULL,'Zenaida','asiatica',177121,NULL),
	(8,'YBCH','Yellow-breasted Chat',NULL,'Icteria','virens',178964,NULL),
	(8,'YBCU','Yellow-billed Cuckoo',NULL,'Coccyzus','americanus',177831,NULL),
	(8,'YBFL','Yellow-bellied Flycatcher',NULL,'Empidonax','flaviventris',178338,NULL),
	(8,'YBSA','Yellow-bellied Sapsucker',NULL,'Sphyrapicus','varius',178202,NULL),
	(8,'YHBL','Yellow-headed Blackbird',NULL,'Xanthocephalus','xanthocephalus',179043,NULL),
	(8,'YRWA','Yellow-rumped Warbler',NULL,'Dendroica','coronata',178891,NULL),
	(8,'YWAR','Yellow Warbler',NULL,'Dendroica','petechia',178878,NULL);

--	(8,'PEEP','Unidentified peep',NULL,NULL,NULL,NULL), # need to change to SHOR

--select * from lu_species order by species_type_id,spp_cd

/*
update lu_species
set
common_name  = 'Herald/Trinidad Petrel',
[group] = 'heraldica and arminjoniana subspecies',
ITIS_id = NULL
where spp_cd = 'HEPE'

select * from lu_species order by species_type_id, spp_cd

 update lu_species
 set
 ITIS_id = NULL,
 scientific_name = NULL
 where spp_cd in ('UNLT','UNMT','UNST','UNTE')
*/
--

-- create and populate survey type table
CREATE TABLE lu_survey_type(
	survey_type_cd nchar(1) not null,
	survey_type_ds nvarchar(50) not null,
	PRIMARY KEY (survey_type_cd)
);
GO 

INSERT INTO lu_survey_type(survey_type_cd,survey_type_ds)
	VALUES
	('a','airplane'),
	('b','boat'),
	('c','camera'),
	('f','fixed ground survey'),
	('g','area-wide ground survey');/*,
	('p','passive acoustics detectors'),
	('d','active acoustic detectors');*/
--

CREATE TABLE lu_platform_name(
	platform_name_id numeric not null,
	platform_name nvarchar(50) not null,
	PRIMARY KEY (platform_name_id)
);
GO 

INSERT INTO lu_platform_name(platform_name_id, platform_name)
	VALUES
	(1,'Atlantic Cat'),
	(2,'Friendship'),
	(3,'R/V Bluefin'),
	(4,'R/V Bulldog'),
	(5,'R/V Cape Hatteras'),
	(6,'R/V Delaware II'),
	(7,'Island Queen'),
	(8,'R/V Oregon I'),
	(9,'R/V Oregon II'),
	(10,'R/V Chapman'),
	(11,'Albatross I'),
	(12,'Albatross II'),
	(13,'Country Girl'),
	(14,'Hatteras Inlet Fever 2'),
	(15,'High Hopes'),
	(16,'Judith M'),
	(17,'Little Clam'),
	(18,'Miss Hatteras'),
	(19,'Stormy Petrel'),
	(20,'TOS Charter'),
	(21,'Chaser'),
	(22,'R/V Henry B. Biglow'),
	(23,'R/V Gordon Gunter'),
	(24,'R/V Pisces'),
	(25,'R/V Gulf Challenger'),--15m 
	(26,'R/V Auk');
--

-- create and populate survey method table
CREATE TABLE lu_survey_method(
	survey_method_cd nchar(3) not null,
	survey_method_ds nchar(50) not null,
	PRIMARY KEY (survey_method_cd)
);
GO 

INSERT INTO lu_survey_method(survey_method_cd,survey_method_ds)
	VALUES
	('byc','bycatch - the unwanted fish and other marine creatures caught during commercial fishing for a different species. These data estimate takes of protected species and discards of fishery resources'),
	('cbc','Christmas Bird count - The Christmas Bird Count (CBC) is a census of birds in the Western Hemisphere, performed annually in the early Northern-hemisphere winter by volunteer birdwatchers and administered by the National Audubon Society.  it''s an extract from Audubon, and thus it''s a copy of data actively maintained elsewhere. If it has been edited since import, we wouldn''t know.'),
	('cts','continuous time strip - ''continuous'' refers to time and the ''strip'' usually denotes a measure of distance from the observer (or platform) perpendicular to the projected path of the observation platform. This method is often along a transect and requires a start and end of the observation period. The observations are then recorded as they occur along the path with exact time and/or location of the observation.'),
	('dth','discrete time horizon - This would be when observations are occurring over a defined time at one single location'),
	('dts','discrete time strip - ''discrete'' refers to time and the ''strip'' usually denotes a measure of distance from the observer (or platform) perpendicular to the projected path of the observation platform. This method denotes all the observations in a defined time unit (e.g. one hour) along the path of observation, so the explicit time or location when that observation occurred along the path is not noted but binned to the center, start, or stop of that given time bin.'), 
	('go','general observation - These would be when an observation is supplied but it was not the primary mission of the event or survey where the species was observed or there are no defining protocols to monitor effort.'),
	('tss','targeted species survey - The defining aspect of this protocol is that only one or a limited few targeted species are observed and all other species that occur in the observation path are not recorded. The ''targeted species'' is a method modifier, where certain data are not recorded but it should still be a Discrete Time Strip or Continuous Time Strip.');
--

--create and populate beaufort table
CREATE TABLE lu_beaufort(
	beaufort_id tinyint not null,
	wind_speed_knots nchar(5) not null,
	WMO_classification nvarchar(50) not null,
	water_ds nvarchar(150) not null,
	PRIMARY KEY(beaufort_id)
);
GO 

INSERT INTO lu_beaufort(beaufort_id,wind_speed_knots,WMO_classification,water_ds)
	VALUES
	(0,'<1','Calm','Sea surface smooth and mirror-like'),
	(1,'1-3','Light Air','Scaly ripples, no foam crests'),
	(2,'4-6','Light Breeze','Small wavelets, crests glassy, no breaking'),
	(3,'7-10','Gentle Breeze','Large wavelets, crests begin to break, scattered whitecaps'),
	(4,'11-16','Moderate Breeze','Small waves 1-4 ft. becoming longer, numerous whitecaps'),
	(5,'17-21','Fresh Breeze','Moderate waves 4-8 ft taking longer form, many whitecaps, some spray'),
	(6,'22-27','Strong Breeze','Larger waves 8-13 ft, whitecaps common, more spray'),
	(7,'28-33','Near Gale','Sea heaps up, waves 13-19 ft, white foam streaks off breakers'),
	(8,'34-40','Gale','Moderately high (18-25 ft) waves of greater length, edges of crests begin to break into spindrift, foam blown in streaks'),
	(9,'41-47','Strong Gale','High waves (23-32 ft), sea begins to roll, dense streaks of foam, spray may reduce visibility'),
	(10,'48-55','Storm','Very high waves (29-41 ft) with overhanging crests, sea white with densely blown foam, heavy rolling, lowered visibility'),
	(11,'56-63','Violent Storm','Exceptionally high (37-52 ft) waves, foam patches cover sea, visibility more reduced'),
	(12,'64+','Hurricane','Air filled with foam, waves over 45 ft, sea completely white with driving spray, visibility greatly reduced');
--


-- look up age
CREATE TABLE lu_age(
	age_id tinyint not null,
	age_ds nvarchar(20) not null
	PRIMARY KEY(age_id) 
);
GO

INSERT INTO lu_age(age_id,age_ds)
	VALUES
	(1,'adult'),
	(2,'juvenile'),
	(3,'mixed'),
	(4,'other'),
	(5,'unknown'),
	(6,'immature'),
	(7,'subadult');
--

-- look up sex
CREATE TABLE lu_sex(
	sex_id tinyint not null,
	sex_ds nvarchar(20) not null
	PRIMARY KEY(sex_id) 
);
GO

INSERT INTO lu_sex(sex_id,sex_ds)
	VALUES
	(1,'female'),
	(2,'male'),
	(3,'mixed'),
	(4,'other'),
	(5,'unknown');
--
	
-- look up behaviors
CREATE TABLE lu_behaviors(
	behavior_id tinyint not null,
	behavior_ds nvarchar(50) not null
	PRIMARY KEY(behavior_id) 
);
GO

INSERT INTO lu_behaviors(behavior_id,behavior_ds)
	VALUES
	(1,'attacking/fighting'),-- 'harassing'
	(2,'basking/sunning'),
	(3,'blow'),
	(4,'bow riding'),
	(5,'breaching'),
	(6,'dead'),
	(7,'diving'), -- %in% c('dive','diving','dove')
	(8,'diving - plunge diving'),
	(9,'feeding'), -- %in% c('feed','feeding')
	(10,'fishing/working'),
	(11,'flocking'),
	(12,'fluking'), -- %in% c('fluke','fluking')
	(13,'flying'), --directional, non-directional,soaring
	(14,'following/chasing'),
	(15,'following - ship'),
	(16,'foraging'),
	(17,'hauled out'), -- %in% c('beached','on beach','on shore') 
	(18,'jumping'), -- 'leaping'
	(19,'landing'),
	(20,'lobtailing'),
	(21,'milling'),
	(22,'mating'),
	(23,'other'),	
	(24,'piracy'),
	(25,'porposing'),
	(26,'preening'),
	(27,'rafting'),
	(28,'resting/floating'),-- logging
	(29,'rolling'),
	(30,'scavenging'),
	(31,'slapping'), -- %in% c('slap','slapping','tailslap','flipperslap')
	(32,'sleeping'),
	(33,'splashing'),
	(34,'spyhopping'),
	(35,'sitting'),
	(36,'sitting - on object'),
	(37,'sitting - on water'),
	(38,'standing'),
	(39,'steaming'), 
	(40,'surfacing'),
	(41,'swimming'),
	(42,'taking off/pattering'),
	(43,'traveling'),
	(44,'unknown');
--

--
CREATE TABLE lu_parent_project(
	project_id tinyint not null,
	project_name nvarchar(55) not null,
	project_ds nvarchar(4000) null,
	project_url nvarchar(3000) null,
	PRIMARY KEY(project_id)
);
GO

INSERT INTO lu_parent_project(
	project_id, project_name, project_ds, project_url)
	VALUES
	(1,'AMAPPS USFWS',
		'The geographic area of operations includes near-shore and offshore waters of the U.S. 
		Atlantic Coast from the Canada/Maine border to approximately Jacksonville, FL. Transects 
		are located at 5'' (~ 5 nautical miles [nm]) intervals at every 1'' and 6'' minutes of 
		latitude. Transect length depends on the location along coast. Some transects extend to 
		16 meter depth or out a distance of 8 nm , whichever is longer. In some cases, transects 
		located near to where the coastline runs east-west have been extended to ensure that the 
		survey covers areas that are at least 8 nm from land. Some transects extend as far as 30 
		nm off-shore to include important seabird foraging areas. In the past these annual surveys 
		were conducted during the winter between January and February. However, when the survey 
		expanded to include all marine bird species the surveys were flown multiple times throughout 
		the year to better determine seabird distributions at different times of year. As a result the 
		surveys are currently conducted in the fall (early October) and winter (early February).  
		Timing can also depend on available funding , data management needs, personnel shortages and 
		availability, weather, and aircraft availability. Surveys are flown during daylight hours 
		with no limits on the time of day. A survey can be initiated when the wind speed is < 15 
		knots (kts), and should be discontinued if the winds exceed 20 kts. Before starting each 
		transect both the pilot and observers will record observation conditions on a 5-point Likert 
		scale with 1 = Worst observation conditions, 3 = Average conditions, and 5 = Best observation 
		conditions. Often times the pilot and observer conditions will be different as glare can affect 
		one side of the aircraft more than the other depending on the direction of flight. Each crew area 
		consists of east-west oriented  strip-transects. Each transect has a unique ID that uses the latitude 
		degrees concatenated with the latitude minutes and then with the segment number [00, 01, etc.]. 
		Typically there will just be one line segment “00”, but when more than one segment occurs on the 
		same latitude you might also have segment “01."( e.g. 444600 or 444601).The transects are flown at 
		a height of 200 feet above ground level and at a speed of 110 knots. Altitude is maintained  
		with the help of a radar altimeter in most cases. Transects extend 30 nautical miles (nm) offshore 
		and can be flown from east to west or west to east.  Each transect is 400 meters (m) in width with 
		200 m observation bands on each side of the aircraft. Each observer counts outward to a the predefined 
		200 m width on their side of the aircraft (left-front (lf) or right-front(rf)).  The pilot serves as 
		the left-front observer (lf) while the observer traditionally sits in the right-front (rf) or co-pilot 
		seat of the aircraft. However, there have been times when a third backseat observer is present (e.g. a 
		new observer being trained). The transect boundary is marked either on the strut with black tape  or the 
		windshield (with dry erase marker) of the plane for reference using a clinometer. The survey targets the 
		fifteen species of sea ducks and all species of marine birds wintering along the Atlantic coast.  Identification 
		of birds to the lowest taxonomic level is ideal (e.g.species), however several generalized  groups have been 
		created for the survey understanding that species identification can be difficult during aerial survey conditions. 
		Such groupings are provided for other species as well including gulls, shearwaters, alcids, and scoters. 
		Observers are also asked to  record all marine mammals, sharks and rays, and sea turtles within the transect. 
		Finally, observers will also record any boats, including those outside of the transect , with an estimated 
		distance in nautical miles. Balloons (both inflated and deflated) should be recording within the transect. 
		[summary snippets copied from internal confluence site]',
		'http://www.nefsc.noaa.gov/psb/AMAPPS/'),
	(2,'AMAPPS NOAA',NULL,'http://www.nefsc.noaa.gov/psb/AMAPPS/'),
	(3,'Audubon CBC (Christmas Bird Count)',NULL,NULL),
	(4,'Bar Harbor Whale Watching Cruises',NULL,NULL),
	(5,'BOEM HighDef NC 2011',NULL,NULL),
	(6,'CDAS Mid-Atlantic',NULL,NULL),
	(7,'CASP (Cetacean and Seabird Assessment Program)',NULL,NULL),
	(8,'DOE BRI aerial',NULL,NULL),
	(9,'DOE BRI boat',NULL,NULL),
	(10,'EcoMon (NEFSC Ecosystem Monitoring) Cruises',
		'Shelf-wide Research Vessel Surveys are conducted 6-7 times per year over the 
		continental shelf from Cape Hatteras, North Carolina to Cape Sable, Nova Scotia, 
		using NOAA research ships or charter vessels. Three surveys are performed jointly 
		with the bottom trawl surveys in the winter, spring and autumn. An additional four 
		cruises, conducted in winter, late spring, late summer and late autumn, are dedicated 
		to plankton and hydrographic data collection. The Cape Hatteras to Cape Sable area is 
		divided into four regions, and 30 randomly selected stations are targeted for sampling from each region.',
		'https://www.nefsc.noaa.gov/HydroAtlas/'),
	(11,'Florida Light and Power, Long Island',NULL,NULL),
	(12,'Herring Acoustic',NULL,NULL),
	(13,'Massachusetts CEC',NULL,NULL),
	(14,'PIROP',NULL,NULL),
	(15,'ECSAS',NULL,NULL),
	(16,'BOEM NanoTag Massachusetts 2013',NULL,NULL),
	(17,'BOEM Terns 2013',NULL,'https://www.boem.gov/2014-665/'),
	(18,'EcoMon/HerringAcoutic combo',NULL,NULL),
	(19,'StellwagenBankNMS standardized transects',NULL,NULL),
	(20,'StellwagenBankNMS Whale Watch',NULL,NULL),
	(21,'BIWF','"Deepwater Wind Rhode Island, LLC (Deepwater) contracted Tetra Tech EC, Inc. (Tetra Tech) to complete 
			a comprehensive baseline assessment of avian and bat resources within and surrounding the Block 
			Island Wind Farm (BIWF) Project Area in an effort to characterize the avian and bat communities and 
			use this information to assess the potential impacts posed to these resources by the proposed BIWF. 
			Surveys were performed in the offshore area where wind turbine generators (WTGs) are proposed as 
			well as adjacent offshore and nearshore areas. In addition, surveys were conducted along the southern 
			coast of Block Island and a portion of the north shore of the Great Salt Pond. Collectively these areas 
			comprised the BIWF Study Area.  
			Surveys that were part of the study included onshore sea-watch point counts, offshore boat-based 
			transects, high definition aerial videography of the offshore portion of the BIWF Study Area, MERLIN 
			avian radar, VESPER vertical profiling radar, Next Generation Weather Radar (NEXRAD) historical 
			migration data review, radar validation, as well as avian acoustic monitoring and passive and active bat 
			acoustic monitoring. These surveys were completed between February 2009 and September 2011. Seawatch 
			point counts, boat-based transects, and aerial videography surveys included identification of 
			species as well as collection of data on abundance and spatial and temporal distributions, while MERLIN 
			and VESPER radars provided additional detailed information on passage rates and flight heights. Bat and 
			avian acoustics were collected to gain insight on nocturnal activity in the Study Area."',
			'http://dwwind.com/project/block-island-wind-farm/'),
	(22,'StellwagenBankNMS second side transects',NULL,NULL),
	(23,'StellwagenBankNMS "other" protocol',NULL,NULL),
	(24,'NYSERDA','"In preparation for offshore wind energy development, the New York State Energy and 
		Research Development Authority (NYSERDA) has initiated the largest offshore high resolution aerial 
		survey of marine and bird life in U.S. history. Normandeau Associates, Inc. and APEM Ltd (Normandeau-APEM team) 
		will gather 3 years of baseline surveys to assess the entire New York Offshore Planning Area (OPA) 
		with particular emphasis on the Wind Energy Area (WEA).  The surveys use ultra-high resolution 
		aerial digital imagery to assess use by birds, marine mammals, turtles, and fish. This proactive 
		study of potential impacts will facilitate a more efficient track to energy production offshore New 
		York by providing the necessary information to meet the U.S. Bureau of Ocean Energy Management''s (BOEM''s) 
		regulatory requirements for environmental review of WEAs." It should be noted that all counts for each record are one. 
	 	The data may need to be combined by date, time, and species to get a total count at that location during that time.
	 	There is also spatial overlap between some transects as well as between OPA and WEA.','https://remote.normandeau.com/nys_overview.php'),
	(25,'GOMCES','During the summers of 2014, 2015 and 2016, a multidisciplinary science team collected ecosystem 
		data within the Gulf of Maine coastal zone (waters ~ 2 – 150 m deep) as part of the Gulf of Maine Coastal 
		Ecosystem Survey (GOMCES). There were 11 transects. Marine bird and mammal surveys were completed using a 
		team of two observers. Team members swapped observation and data recording responsibilities between each 
		section of transect between cast stations (transect segment). While on transect, the data observer was positioned 
		at the bow of the vessel to complete marine bird and mammal observations equipped with 10x50 binoculars. 
		The observer identified, counted, and documented the behavior of each marine bird and marine mammal within 
		an observation square delineated by the line of travel of the vessel and a 90o perpendicular angle to the line 
		of travel one side of the vessel. Using distance sampling protocol (Buckland et al. 2001, 2008), the observer 
		also estimated the radial distance and angle between each animal and the observer (Tasker et al. 1984). These 
		data were relayed to the data recorder using two-way radios (Motorola Talkabout Two Way Radios MS350R) with headset 
		attachment (XLT HS500 Heavy Duty Dual Muff headset with PTT and Mic with push-to-talk) to the data recorder, who 
		entered the data in real-time on a computer connected directly to a GPS unit using the program DLog 
		(R. G. Ford Inc., Portland, OR), such that each sighting had a specific time and location stamp. Each sighting 
		record also included observation variables (e.g., glare, visibility, wave height, weather).',
		'https://gomces.wordpress.com/');

--	project_id, project_name, project_ds, project_url

/*  update lu_parent_project table */
/*  update lu_parent_project
	set
	project_name = 'AMAPPS NOAA'
	where project_id = 2
*/

-- select * from lu_parent_project

------------------------
-- create main tables --
------------------------

-- create dataset table
CREATE TABLE dataset (
	dataset_id smallint not null,
	dataset_name nvarchar(50) not null,
	survey_type_cd nchar(1) null,
	survey_method_cd nchar(3) null,
	platform_name_id numeric null,
	dataset_type_cd nchar(2) null, 
	whole_survey_width_m smallint null,
	individual_observer_survey_width_m smallint null,
	share_level_id tinyint not null, 
	sponsors nvarchar(50) null,
	planned_speed_knots numeric null,
	pooled_observations nchar(3) null, --yes/no
	responsible_party smallint null, 
	in_database nchar(3) not null, --yes/no
	metadata nvarchar(3000) null,
	parent_project tinyint null, 
	dataset_summary nvarchar(4000) null, 
	dataset_quality nvarchar(3000) null, 
	dataset_processing nvarchar(3000) null,
	version_nb tinyint null, 
	additional_info nvarchar(1000) null,
	data_url nvarchar(2083) null,
	report nvarchar(2083) null,
	data_citation nvarchar(2000) null,
	publications nvarchar(2000) null,
	publication_url nvarchar(2000) null,
	publication_DOI nvarchar(2000) null,
	PRIMARY KEY(dataset_id),
	FOREIGN KEY(survey_method_cd) REFERENCES lu_survey_method(survey_method_cd),
	FOREIGN KEY(platform_name_id) REFERENCES lu_platform_name(platform_name_id),
	FOREIGN KEY(dataset_type_cd) REFERENCES lu_dataset_type(dataset_type_cd),
	FOREIGN KEY(survey_type_cd) REFERENCES lu_survey_type(survey_type_cd),
	FOREIGN KEY(share_level_id) REFERENCES lu_share_level(share_level_id),
	--FOREIGN KEY(dataset_id, version_nb) REFERENCES lu_revision_details(dataset_id, version_nb),
	FOREIGN KEY(responsible_party) REFERENCES lu_people([user_id]),
	FOREIGN KEY(parent_project) REFERENCES lu_parent_project(project_id),
);
GO
-- select * from lu_revision_details

--select * from dataset --order by share_level_id --order by in_database
INSERT INTO dataset(
	dataset_id, parent_project, dataset_name, survey_type_cd, survey_method_cd,
	dataset_type_cd, whole_survey_width_m, individual_observer_survey_width_m,
	share_level_id, in_database, pooled_observations, responsible_party,
	sponsors,planned_speed_knots, version_nb, platform_name_id)--,
--dataset_summary, dataset_quality, dataset_processing)
	VALUES
 	(141,1,'AMAPPS_FWS_Aerial_Fall2012','a','cts','ot',400,200,5,'yes','no',50,'BOEM,USFWS,NOAA,NAVY',110,1,NULL),
 	(142,1,'AMAPPS_FWS_Aerial_Fall2013','a','cts','ot',400,200,5,'yes','no',64,'BOEM,USFWS,NOAA,NAVY',110,1,NULL),
 	(164,1,'AMAPPS_FWS_Aerial_Fall2014','a','cts','ot',400,200,5,'yes','no',64,'BOEM,USFWS,NOAA,NAVY',110,1,NULL),
 	(118,1,'AMAPPS_FWS_Aerial_Preliminary_Summer2010','a','cts','ot',400,200,5,'yes','no',50,'BOEM,USFWS,NOAA,NAVY',110,1,NULL),
 	(140,1,'AMAPPS_FWS_Aerial_Spring2012','a','cts','ot',400,200,5,'yes','no',50,'BOEM,USFWS,NOAA,NAVY',110,1,NULL),
 	(138,1,'AMAPPS_FWS_Aerial_Summer2011','a','cts','ot',400,200,5,'yes','no',50,'BOEM,USFWS,NOAA,NAVY',110,1,NULL),
 	(137,1,'AMAPPS_FWS_Aerial_Winter2010-2011','a','cts','ot',400,200,5,'yes','no',50,'BOEM,USFWS,NOAA,NAVY',110,1,NULL),
 	(139,1,'AMAPPS_FWS_Aerial_Winter2014','a','cts','ot',400,200,5,'yes','no',64,'BOEM,USFWS,NOAA,NAVY',110,1,NULL),
	(117,2,'AMAPPS_NOAA/NMFS_NEFSCBoat2011','b','cts','ot',300,300,5,'yes','yes',55,'BOEM,USFWS,NOAA,NAVY',NULL,1,NULL),
	(116,2,'AMAPPS_NOAA/NMFS_NEFSCBoat2013','b','cts','ot',300,300,5,'yes','yes',55,'BOEM,USFWS,NOAA,NAVY',NULL,1,NULL),
	(149,2,'AMAPPS_NOAA/NMFS_NEFSCBoat2014','b','cts','ot',300,300,5,'yes','yes',55,'BOEM,USFWS,NOAA,NAVY',NULL,1,NULL),
	(160,2,'AMAPPS_NOAA/NMFS_NEFSCBoat2015','b','cts','ot',300,300,5,'yes','yes',52,'BOEM,USFWS,NOAA,NAVY',NULL,1,NULL),
	(174,2,'AMAPPS_NOAA/NMFS_NEFSCBoat2016','b','cts','ot',300,300,9,'yes','yes',52,'BOEM,USFWS,NOAA,NAVY',NULL,1,NULL),
	(122,2,'AMAPPS_NOAA/NMFS_SEFSCBoat2011','b','cts','ot',300,300,5,'yes','yes',55,'BOEM,USFWS,NOAA,NAVY',NULL,1,NULL),
	(123,2,'AMAPPS_NOAA/NMFS_SEFSCBoat2013','b','cts','ot',300,300,5,'yes','yes',55,'BOEM,USFWS,NOAA,NAVY',NULL,1,NULL),
	(100,NULL,'AtlanticFlywaySeaducks1991',NULL,NULL,NULL,NULL,NULL,0,'no',NULL,NULL,'USFWS',NULL,1,NULL),				
	(43,3,'AudubonCBC_MA2Z','g','cbc','og',NULL,NULL,5,'yes','yes',8,NULL,NULL,1,NULL),        		
	(46,3,'AudubonCBC_MASB','g','cbc','og',NULL,NULL,5,'yes','yes',8,NULL,NULL,1,NULL),         		
	(47,3,'AudubonCBC_MD15','g','cbc','og',NULL,NULL,5,'yes','yes',8,NULL,NULL,1,NULL),         		
	(48,3,'AudubonCBC_MD19','g','cbc','og',NULL,NULL,5,'yes','yes',8,NULL,NULL,1,NULL),         		
	(49,3,'AudubonCBC_MDBH','g','cbc','og',NULL,NULL,5,'yes','yes',8,NULL,NULL,1,NULL),         		
	(50,3,'AudubonCBC_MDJB','g','cbc','og',NULL,NULL,5,'yes','yes',8,NULL,NULL,1,NULL),         		
	(51,3,'AudubonCBC_ME08','g','cbc','og',NULL,NULL,5,'yes','yes',8,NULL,NULL,1,NULL),         		
	(52,3,'AudubonCBC_ME0A','g','cbc','og',NULL,NULL,5,'yes','yes',8,NULL,NULL,1,NULL),         		
	(53,3,'AudubonCBC_ME0B','g','cbc','og',NULL,NULL,5,'yes','yes',8,NULL,NULL,1,NULL),         		
	(54,3,'AudubonCBC_MEBF','g','cbc','og',NULL,NULL,5,'yes','yes',8,NULL,NULL,1,NULL),         		
	(55,3,'AudubonCBC_MEMB','g','cbc','og',NULL,NULL,5,'yes','yes',8,NULL,NULL,1,NULL),         		
	(56,3,'AudubonCBC_NJ0A','g','cbc','og',NULL,NULL,5,'yes','yes',8,NULL,NULL,1,NULL),         		
	(57,3,'AudubonCBC_NJ0R','g','cbc','og',NULL,NULL,5,'yes','yes',8,NULL,NULL,1,NULL),         		
	(58,3,'AudubonCBC_NJ0S','g','cbc','og',NULL,NULL,5,'yes','yes',8,NULL,NULL,1,NULL),         		
	(59,3,'AudubonCBC_NJAO','g','cbc','og',NULL,NULL,5,'yes','yes',8,NULL,NULL,1,NULL),         		
	(60,3,'AudubonCBC_NJNJ','g','cbc','og',NULL,NULL,5,'yes','yes',8,NULL,NULL,1,NULL),         		
	(61,3,'AudubonCBC_NY1Q','g','cbc','og',NULL,NULL,5,'yes','yes',7,NULL,NULL,1,NULL),         		
	(62,3,'AudubonCBC_NY1R','g','cbc','og',NULL,NULL,5,'yes','yes',8,NULL,NULL,1,NULL),         		
	(63,3,'AudubonCBC_NY1S','g','cbc','og',NULL,NULL,5,'yes','yes',8,NULL,NULL,1,NULL),         		
	(64,3,'AudubonCBC_NY1W','g','cbc','og',NULL,NULL,5,'yes','yes',8,NULL,NULL,1,NULL),         		
	(65,3,'AudubonCBC_NY1X','g','cbc','og',NULL,NULL,5,'yes','yes',8,NULL,NULL,1,NULL),         		
	(66,3,'AudubonCBC_NY21','g','cbc','og',NULL,NULL,5,'yes','yes',8,NULL,NULL,1,NULL),         		
	(67,3,'AudubonCBC_NY39','g','cbc','og',NULL,NULL,5,'yes','yes',8,NULL,NULL,1,NULL),         		
	(68,3,'AudubonCBC_VACB','g','cbc','og',NULL,NULL,5,'yes','yes',8,NULL,NULL,1,NULL),         		
	(107,NULL,'AvalonSeawatch1993',NULL,NULL,NULL,NULL,NULL,0,'no',NULL,21,NULL,NULL,1,NULL), 					
	(5,4,'BarHarborWW05','b','cts','ot',NULL,NULL,5,'yes','yes',33,'USFWS',NULL,1,NULL),         		
	(6,4,'BarHarborWW06','b','cts','ot',NULL,NULL,5,'yes','yes',33,'USFWS',NULL,1,NULL),         		
	(166,4,'BarHarborWW09','b','cts','ot',NULL,NULL,0,'no',NULL,33,'USFWS',NULL,1,NULL), 		
	(167,4,'BarHarborWW10','b','cts','ot',NULL,NULL,0,'no',NULL,33,'USFWS',NULL,1,NULL), 		
	(103,NULL,'BluewaterWindDE',NULL,NULL,NULL,NULL,NULL,0,'no',NULL,40,'BOEM',NULL,1,NULL), 					
	(102,NULL,'BluewaterWindNJ',NULL,NULL,NULL,NULL,NULL,0,'no',NULL,40,'BOEM',NULL,1,NULL), 					
	(144,5,'BOEMHighDef_NC2011Aerial','a','cts','ot',500,250,5,'yes','no',61,'BOEM,Normandeau',NULL,1,NULL), 
	(143,5,'BOEMHighDef_NC2011Boat','b','cts','ot',1000,1000,5,'yes','no',61,'BOEM,Normandeau',NULL,1,NULL), 
	(169,5,'BOEMHighDef_NC2011Camera','c','cts','ot',NULL,NULL,99,'no','yes',61,'BOEM,Normandeau',NULL,1,NULL), 		 			
	(172,NULL,'BRIMaine2016','b','cts','ot',1500,1500,9,'no',NULL,66,'BRI,Maine gov',NULL,1,NULL), 		
	(7,NULL,'CapeHatteras0405','b','cts','ot',NULL,NULL,5,'yes',NULL,23,'Duke',NULL,1,NULL),         		
	(8,NULL,'CapeWindAerial','a','cts','ot',NULL,NULL,2,'yes','yes',13,'BOEM',NULL,1,NULL),       		
	(9,NULL,'CapeWindBoat','b','cts','ot',NULL,NULL,2,'yes','yes',13,'BOEM',NULL,1,NULL),         		
	(10,6,'CDASMidAtlantic','a','cts','ot',120,60,5,'yes','yes',15,NULL,NULL,1,NULL),
	(21,7,'CSAP','b','dts','ot',300,300,5,'yes','yes',31,'Manomet',NULL,1,NULL),
	(97,NULL,'DEandChesBaysUSFWS1990',NULL,NULL,NULL,NULL,NULL,6,'no',NULL,15,'USFWS',NULL,1,NULL), 		 					
	(115,8,'DOEBRIAerial2012','c','cts','ot',200,50,1,'yes','yes',3,'DOE,BRI,BOEM',NULL,1,NULL),--check on share levels
	(148,8,'DOEBRIAerial2013','c','cts','ot ',200,50,1,'yes','yes',3,'DOE,BRI,BOEM',NULL,1,NULL),--check on share levels
	(168,8,'DOEBRIAerial2014','c','cts','ot',200,50,1,'yes','yes',3,'DOE,BRI,BOEM',NULL,1,NULL),--check on share levels
	(157,9,'DOEBRIBoatApr2014','b','cts','ot',300,300,1,'yes','yes',3,'DOE,BRI,BOEM',NULL,1,NULL),
	(114,9,'DOEBRIBoatApril2012','b','cts','ot',300,300,1,'yes','yes',3,'DOE,BRI,BOEM',NULL,1,NULL),
	(124,9,'DOEBRIBoatAug2012','b','cts','ot',300,300,1,'yes','yes',3,'DOE,BRI,BOEM',NULL,1,NULL),
	(152,9,'DOEBRIBoatAug2013','b','cts','ot',300,300,1,'yes','yes',3,'DOE,BRI,BOEM',NULL,1,NULL),
	(125,9,'DOEBRIBoatDec2012','b','cts','ot',300,300,1,'yes','yes',3,'DOE,BRI,BOEM',NULL,1,NULL),
	(155,9,'DOEBRIBoatDec2013','b','cts','ot',300,300,1,'yes','yes',3,'DOE,BRI,BOEM',NULL,1,NULL),
	(126,9,'DOEBRIBoatJan2013','b','cts','ot',300,300,1,'yes','yes',3,'DOE,BRI,BOEM',NULL,1,NULL),
	(156,9,'DOEBRIBoatJan2014','b','cts','ot',300,300,1,'yes','yes',3,'DOE,BRI,BOEM',NULL,1,NULL),
	(127,9,'DOEBRIBoatJune2012','b','cts','ot',300,300,1,'yes','yes',3,'DOE,BRI,BOEM',NULL,1,NULL),
	(151,9,'DOEBRIBoatJune2013','b','cts','ot',300,300,1,'yes','yes',3,'DOE,BRI,BOEM',NULL,1,NULL),
	(128,9,'DOEBRIBoatMar2013','b','cts','ot',300,300,1,'yes','yes',3,'DOE,BRI,BOEM',NULL,1,NULL),
	(150,9,'DOEBRIBoatMay2013','b','cts','ot',300,300,1,'yes','yes',3,'DOE,BRI,BOEM',NULL,1,NULL),
	(130,9,'DOEBRIBoatNov2012','b','cts','ot',300,300,1,'yes','yes',3,'DOE,BRI,BOEM',NULL,1,NULL),
	(154,9,'DOEBRIBoatOct2013','b','cts','ot',300,300,1,'yes','yes',3,'DOE,BRI,BOEM',NULL,1,NULL),
	(129,9,'DOEBRIBoatSep2012','b','cts','ot',300,300,1,'yes','yes',3,'DOE,BRI,BOEM',NULL,1,NULL),
	(153,9,'DOEBRIBoatSep2013','b','cts','ot',300,300,1,'yes','yes',3,'DOE,BRI,BOEM',NULL,1,NULL),
	(134,NULL,'DominionVirginia_VOWTAP','b','cts','ot',300,300,5,'yes','yes',65,'BOEM,Dominion,TetraTech',NULL,1,NULL),
	(101,NULL,'DUMLOnslowBay2007',NULL,NULL,NULL,NULL,NULL,0,'no',NULL,36,'Duke, University of NC',NULL,1,NULL),					
	(77,10,'EcoMonAug08','b','cts','ot',300,300,5,'yes','yes',11,'NOAA',NULL,1,NULL),
	(42,10,'EcoMonAug09','b','cts','ot',300,300,5,'yes','yes',11,'NOAA',NULL,1,NULL),
	(82,10,'EcoMonAug10','b','cts','ot',300,300,5,'yes','yes',11,'NOAA',NULL,1,NULL),
	(112,10,'EcoMonAug2012','b','cts','ot',300,300,5,'yes','yes',11,'NOAA',NULL,1,NULL),
	(79,10,'EcoMonFeb10','b','cts','ot',300,300,5,'yes','yes',11,'NOAA',NULL,1,NULL),
	(131,10,'EcoMonFeb2012','b','cts','ot',300,300,5,'yes','yes',11,'NOAA',NULL,1,NULL),
	(171,10,'EcoMonFeb2013','b','cts','ot',300,300,5,'yes','yes',62,'NOAA',NULL,1,NULL),
	(38,10,'EcoMonJan09','b','cts','ot',300,300,5,'yes','yes',11,'NOAA',NULL,1,NULL),
	(158,10,'EcoMonJun2012','b','cts','ot',300,300,5,'yes','yes',11,'NOAA',NULL,1,NULL),
	(33,10,'EcoMonMay07','b','cts','ot',300,300,5,'yes','yes',11,'NOAA',NULL,1,NULL),
	(39,10,'EcoMonMay09','b','cts','ot',300,300,5,'yes','yes',11,'NOAA',NULL,1,NULL),
	(80,10,'EcoMonMay10','b','cts','ot',300,300,5,'yes','yes',11,'NOAA',NULL,1,NULL),
	(76,10,'EcoMonNov09','b','cts','ot',300,300,5,'yes','yes',11,'NOAA',NULL,1,NULL),
	(81,10,'EcoMonNov10','b','cts','ot',300,300,5,'yes','yes',11,'NOAA',NULL,1,NULL),
	(83,10,'EcoMonNov2011','b','cts','ot',300,300,5,'yes','yes',11,'NOAA',NULL,1,NULL),
	(159,10,'EcoMonOct2012','b','cts','ot',300,300,5,'yes','yes',11,'NOAA',NULL,1,NULL),
	(170,10,'EcoMonSep2012',NULL,NULL,NULL,NULL,NULL,6,'no',NULL,NULL,NULL,NULL,1,NULL),
	(119,15,'ECSAS','b','cts','ot',300,300,0,'no',NULL,16,NULL,NULL,1,NULL),
	(99,11,'FLPowerLongIsland_Aerial','a','cts','ot',400,200,5,'yes','yes',65,'BOEM, Florida Light and Power',NULL,1,NULL),
	(165,11,'FLPowerLongIsland_Boat','b','cts','ot',300,300,5,'yes','yes',65,'BOEM, Florida Light and Power',NULL,1,NULL),
	(147,NULL,'FWS_MidAtlanticDetection_Spring2012','a','cts','ot',400,200,5,'yes','no',59,'USFWS',NULL,1,NULL),
	(146,NULL,'FWS_SouthernBLSC_Winter2012','a','cts','ot',400,200,5,'yes','no',59,'USFWS',NULL,1,NULL),
	(113,NULL,'FWSAtlanticWinterSeaduck2008','a','cts','ot',400,200,5,'yes','no',58,'USFWS',NULL,1,NULL),
	(12,NULL,'GeorgiaPelagic','b','dts','ot',NULL,NULL,5,'yes',NULL,20,NULL,NULL,1,NULL),        		
	(110,NULL,'GulfOfMaineBluenose1965',NULL,NULL,NULL,NULL,NULL,0,'no',NULL,NULL,NULL,NULL,1,NULL),   					
	(73,NULL,'HassNC','b','tss','ot',NULL,NULL,5,'yes',NULL,42,NULL,NULL,1,NULL),         		
	(15,NULL,'HatterasEddyCruise2004','b','cts','ot',NULL,NULL,5,'yes',NULL,27,NULL,NULL,1,NULL),         		
	(78,12,'HerringAcoustic06','b','cts','ot',300,300,5,'yes','yes',11,'NOAA',NULL,1,NULL),
	(34,12,'HerringAcoustic07','b','cts','ot',300,300,5,'yes','yes',11,'NOAA',NULL,1,NULL),
	(35,12,'HerringAcoustic08','b','cts','ot',300,300,5,'yes','yes',11,'NOAA',NULL,1,NULL),
	(69,12,'HerringAcoustic09Leg1','b','cts','ot',300,300,5,'yes','yes',11,'NOAA',NULL,1,NULL),
	(70,12,'HerringAcoustic09Leg2','b','cts','ot',300,300,5,'yes','yes',11,'NOAA',NULL,1,NULL),
	(71,12,'HerringAcoustic09Leg3','b','cts','ot',300,300,5,'yes','yes',11,'NOAA',NULL,1,NULL),
	(84,12,'HerringAcoustic2010','b','cts','ot',300,300,5,'yes','yes',11,'NOAA',NULL,1,NULL),
	(85,12,'HerringAcoustic2011','b','cts','ot',300,300,5,'yes','yes',11,'NOAA',NULL,1,NULL),
	(111,12,'HerringAcoustic2012','b','cts','ot',300,300,5,'yes','yes',62,'NOAA',NULL,1,NULL),
	(22,NULL,'MassAudNanAerial','a','cts','ot',182,91,5,'yes','yes',10,NULL,NULL,1,NULL),
	(135,13,'MassCEC2011-2012','a','cts','ot',400,200,5,'yes','no',62,NULL,NULL,2,NULL),
	(161,13,'MassCEC2013','a','cts','ot',400,200,5,'yes','no',62,NULL,NULL,1,NULL),
	(162,13,'MassCEC2014','a','cts','ot',400,200,5,'yes','no',62,NULL,NULL,1,NULL),
	(74,NULL,'Mayr1938TransAtlantic','b','go','og',NULL,NULL,5,'yes',NULL,NULL,NULL,NULL,1,NULL),--check        		
	(136,13,'NantucketAerial2013','a','cts','ot',NULL,NULL,7,'yes',NULL,62,NULL,NULL,1,NULL),		
	(96,NULL,'NantucketShoalsLTDU1998',NULL,NULL,NULL,NULL,NULL,0,'no',NULL,NULL,NULL,NULL,1,NULL),					
	(105,NULL,'NCInletsDavidLee1976',NULL,NULL,NULL,NULL,NULL,0,'no',NULL,22,NULL,NULL,1,NULL),					
	(109,NULL,'NewEnglandBlueDolphin1953',NULL,NULL,NULL,NULL,NULL,0,'no',NULL,25,NULL,NULL,1,NULL),					
	(25,NULL,'NewEnglandSeamount06','b','dts','ot',NULL,NULL,5,'yes',NULL,16,NULL,NULL,1,NULL),        		
	(91,NULL,'NJDEP2009','b','cts','de',300,300,5,'yes','yes',56,'NJDEP,BOEM',NULL,1,NULL),
	(121,NULL,'NOAA/NMFS_NEFSCBoat2004','b','cts','ot',300,300,5,'yes','yes',52,'NOAA',10,1,NULL),
	(120,NULL,'NOAA/NMFS_NEFSCBoat2007','b','cts','ot',300,300,5,'yes','yes',52,'NOAA',11,1,NULL),
	(32,NULL,'NOAABycatch','b','byc','og',NULL,NULL,5,'yes',NULL,19,'NOAA',NULL,1,NULL),        		
	(20,NULL,'NOAAMBO7880','b','dts','ot',300,300,5,'yes','yes',15,'NOAA',NULL,1,NULL),   					
	(23,NULL,'Patteson','b','go','og',NULL,NULL,5,'yes',NULL,32,NULL,NULL,1,NULL),        		
	(92,NULL,'PIROP','b',NULL,NULL,NULL,NULL,7,'yes',NULL,16,NULL,NULL,1,NULL),				
	(75,NULL,'PlattsBankAerial','a','cts','ot',340,170 ,5,'yes',NULL,39,NULL,99.892,1,NULL),        		
	(98,NULL,'RHWiley1957',NULL,NULL,NULL,NULL,NULL,0,'no',NULL,26,NULL,NULL,1,NULL),					
	(89,NULL,'RISAMPAerial','a','cts','ot',300,300,5,'yes','yes',41,NULL,NULL,1,NULL),
	(90,NULL,'RISAMPBoat','b','cts','ot',300,300,5,'yes','yes',41,NULL,NULL,1,NULL),
	(104,NULL,'RockportSeawatch',NULL,NULL,NULL,NULL,NULL,0,'no',NULL,NULL,NULL,NULL,1,NULL),					
	(108,NULL,'RowlettMaryland1971',NULL,NULL,NULL,NULL,NULL,0,'no',NULL,24,NULL,NULL,1,NULL),					
	(163,NULL,'RoyalSociety',NULL,NULL,NULL,NULL,NULL,0,'no',NULL,NULL,NULL,NULL,1,NULL),					
	(24,NULL,'SargassoSea04','b','go','og',NULL,NULL,5,'yes',NULL,28,'Duke',NULL,1,NULL),	       		
	(28,NULL,'SargassoSea06','b','go','og',NULL,NULL,5,'yes',NULL,34,'Duke',NULL,1,NULL),	        		
	(93,NULL,'SEANET','g',NULL,NULL,NULL,NULL,0,'no',NULL,43,'Tufts,Wildlife Clinic',NULL,1,NULL),					
	(29,NULL,'SEFSC1992','b','cts','ot',300,300,5,'yes','yes',30,'NOAA',NULL,1,NULL),
	(30,NULL,'SEFSC1998','b','cts','ot',300,300,5,'yes','yes',30,'NOAA',NULL,1,NULL),
	(31,NULL,'SEFSC1999','b','cts','ot',300,300,5,'yes','yes',30,'NOAA',NULL,1,NULL),
	(133,NULL,'StatoilMaine','b','cts','ot',300,300,5,'yes','yes',65,'BOEM,StatOil,TetraTech',10,1,NULL),				
	(106,NULL,'WaterfowlUSFWS2001',NULL,NULL,NULL,NULL,NULL,0,'no',NULL,14,'USFWS',NULL,1,NULL),					
	(94,NULL,'WHOIJuly2010','b','cts','ot',300,300,1,'yes',NULL,11,'WHOI',NULL,1,NULL),
	(132,NULL,'WHOISept2010','b','cts','ot',300,300,1,'yes',NULL,11,'WHOI',NULL,1,NULL),
	(145,16,'BOEMNanoTag_Mass_Aug2013','a','tss','ot',400,200,5,'yes','yes',60,'BOEM,USFWS',110,1,NULL),
	(176,16,'BOEMNanoTag_Mass_Sept2013a','a','tss','ot',400,200,5,'yes','yes',60,'BOEM,USFWS',110,1,NULL),
	(177,16,'BOEMNanoTag_Mass_Sept2013b','a','tss','ot',400,200,5,'yes','yes',60,'BOEM,USFWS',110,1,NULL),
	(178,17,'BOEM_terns_July2013','a','tss','ot',400,200,5,'yes','no',62,'BOEM',100,1,NULL),
	(179,17,'BOEM_terns_Aug2013','a','tss','ot',400,200,5,'yes','no',62,'BOEM',100,1,NULL),
	(180,17,'BOEM_terns_Sep2013a','a','tss','ot',400,200,5,'yes','no',62,'BOEM',100,1,NULL),
 	(181,17,'BOEM_terns_Sep2013b','a','tss','ot',400,200,5,'yes','no',62,'BOEM',100,1,NULL),
	(95,19,'StellwagenBankNMS_Jun2012','b','cts','ot',300,300,99,'no',NULL,9,'NOAA',NULL,1,26),	
	(182,19,'StellwagenBankNMS_Aug2012','b','cts','ot',300,300,99,'no',NULL,9,'NOAA',NULL,1,26),
	(183,19,'StellwagenBankNMS_Oct2012','b','cts','ot',300,300,99,'no',NULL,9,'NOAA',NULL,1,26),
	(184,19,'StellwagenBankNMS_Jan2013','b','cts','ot',300,300,99,'no',NULL,9,'NOAA',NULL,1,26),
	(185,19,'StellwagenBankNMS_Apr2013','b','cts','ot',300,300,99,'no',NULL,9,'NOAA',NULL,1,26),
	(186,19,'StellwagenBankNMS_Jun2013','b','cts','ot',300,300,99,'no',NULL,9,'NOAA',NULL,1,26),
	(187,19,'StellwagenBankNMS_Aug2013','b','cts','ot',300,300,99,'no',NULL,9,'NOAA',NULL,1,26),
	(188,19,'StellwagenBankNMS_Oct2013','b','cts','ot',300,300,99,'no',NULL,9,'NOAA',NULL,1,26),
	(189,19,'StellwagenBankNMS_Apr2014','b','cts','ot',300,300,99,'no',NULL,9,'NOAA',NULL,1,26),
	(190,19,'StellwagenBankNMS_Jun2014','b','cts','ot',300,300,99,'no',NULL,9,'NOAA',NULL,1,26),
	(191,19,'StellwagenBankNMS_Aug2014','b','cts','ot',300,300,99,'no',NULL,9,'NOAA',NULL,1,26),
	(192,19,'StellwagenBankNMS_Sep2014','b','cts','ot',300,300,99,'no',NULL,9,'NOAA',NULL,1,26),
	(193,19,'StellwagenBankNMS_Oct2014','b','cts','ot',300,300,99,'no',NULL,9,'NOAA',NULL,1,26),
	(194,19,'StellwagenBankNMS_Dec2014','b','cts','ot',300,300,99,'no',NULL,9,'NOAA',NULL,1,26),
	(195,19,'StellwagenBankNMS_Jun2015','b','cts','ot',300,300,99,'no',NULL,9,'NOAA',NULL,1,26),
	(196,19,'StellwagenBankNMS_Aug2015','b','cts','ot',300,300,99,'no',NULL,9,'NOAA',NULL,1,26),
	(197,19,'StellwagenBankNMS_Sep2015','b','cts','ot',300,300,99,'no',NULL,9,'NOAA',NULL,1,26),
	(198,19,'StellwagenBankNMS_Oct2015','b','cts','ot',300,300,99,'no',NULL,9,'NOAA',NULL,1,26),
	(199,19,'StellwagenBankNMS_Dec2015','b','cts','ot',300,300,99,'no',NULL,9,'NOAA',NULL,1,26),
	(200,19,'StellwagenBankNMS_Aug2011','b','cts','ot',300,300,99,'no',NULL,9,'NOAA',NULL,1,NULL),
	(201,19,'StellwagenBankNMS_Sep2011a','b','cts','ot',300,300,99,'no',NULL,9,'NOAA',NULL,1,NULL),--two surveys in Sep.
	(202,19,'StellwagenBankNMS_Sep2011b','b','cts','ot',300,300,99,'no',NULL,9,'NOAA',NULL,1,NULL),--two surveys in Sep.
	(203,19,'StellwagenBankNMS_Dec2011','b','cts','ot',300,300,99,'no',NULL,9,'NOAA',NULL,1,NULL),
	(204,19,'StellwagenBankNMS_Oct2011','b','cts','ot',300,300,99,'no',NULL,9,'NOAA',NULL,1,NULL),
	(175,21,'DeepwaterWindBlockIsland_boat_Nov09a','b','cts','ot',300,300,9,'no',NULL,65,'BOEM,TetraTech,Deepwater Wind RI',8,1,NULL),
	(205,21,'DeepwaterWindBlockIsland_boat_Nov09b','b','cts','ot',300,300,9,'no',NULL,65,'BOEM,TetraTech,Deepwater Wind RI',8,1,NULL),
	(206,21,'DeepwaterWindBlockIsland_boat_Dec10a','b','cts','ot',300,300,9,'no',NULL,65,'BOEM,TetraTech,Deepwater Wind RI',8,1,NULL),
	(207,21,'DeepwaterWindBlockIsland_boat_Dec10b','b','cts','ot',300,300,9,'no',NULL,65,'BOEM,TetraTech,Deepwater Wind RI',8,1,NULL),
	(208,21,'DeepwaterWindBlockIsland_boat_Jan10a','b','cts','ot',300,300,9,'no',NULL,65,'BOEM,TetraTech,Deepwater Wind RI',8,1,NULL),
	(209,21,'DeepwaterWindBlockIsland_boat_Jan10b','b','cts','ot',300,300,9,'no',NULL,65,'BOEM,TetraTech,Deepwater Wind RI',8,1,NULL),
	(210,21,'DeepwaterWindBlockIsland_boat_Feb10a','b','cts','ot',300,300,9,'no',NULL,65,'BOEM,TetraTech,Deepwater Wind RI',8,1,NULL),
	(211,21,'DeepwaterWindBlockIsland_boat_Feb10b','b','cts','ot',300,300,9,'no',NULL,65,'BOEM,TetraTech,Deepwater Wind RI',8,1,NULL),
	(212,21,'DeepwaterWindBlockIsland_boat_Mar10a','b','cts','ot',300,300,9,'no',NULL,65,'BOEM,TetraTech,Deepwater Wind RI',8,1,NULL),
	(213,21,'DeepwaterWindBlockIsland_boat_Mar10b','b','cts','ot',300,300,9,'no',NULL,65,'BOEM,TetraTech,Deepwater Wind RI',8,1,NULL),
	(214,21,'DeepwaterWindBlockIsland_boat_Apr10a','b','cts','ot',300,300,9,'no',NULL,65,'BOEM,TetraTech,Deepwater Wind RI',8,1,NULL),
	(215,21,'DeepwaterWindBlockIsland_boat_Apr10b','b','cts','ot',300,300,9,'no',NULL,65,'BOEM,TetraTech,Deepwater Wind RI',8,1,NULL),
	(216,21,'DeepwaterWindBlockIsland_boat_May10a','b','cts','ot',300,300,9,'no',NULL,65,'BOEM,TetraTech,Deepwater Wind RI',8,1,NULL),
	(217,21,'DeepwaterWindBlockIsland_boat_May10b','b','cts','ot',300,300,9,'no',NULL,65,'BOEM,TetraTech,Deepwater Wind RI',8,1,NULL),
	(218,21,'DeepwaterWindBlockIsland_boat_Jun10a','b','cts','ot',300,300,9,'no',NULL,65,'BOEM,TetraTech,Deepwater Wind RI',8,1,NULL),
 	(219,21,'DeepwaterWindBlockIsland_boat_Jun10b','b','cts','ot',300,300,9,'no',NULL,65,'BOEM,TetraTech,Deepwater Wind RI',8,1,NULL),
 	(220,21,'DeepwaterWindBlockIsland_boat_Aug11a','b','cts','ot',300,300,0,'no',NULL,65,'BOEM,TetraTech,Deepwater Wind RI',8,1,NULL),
 	(221,21,'DeepwaterWindBlockIsland_boat_Aug11b','b','cts','ot',300,300,0,'no',NULL,65,'BOEM,TetraTech,Deepwater Wind RI',8,1,NULL),
 	(222,21,'DeepwaterWindBlockIsland_boat_Sep11a','b','cts','ot',300,300,0,'no',NULL,65,'BOEM,TetraTech,Deepwater Wind RI',8,1,NULL),
	(223,21,'DeepwaterWindBlockIsland_boat_Sep11b','b','cts','ot',300,300,0,'no',NULL,65,'BOEM,TetraTech,Deepwater Wind RI',8,1,NULL),
	(224,22,'StellwagenBankNMS_SS_Jun2012','b','cts','ot',NULL,NULL,99,'no',NULL,9,'NOAA',NULL,1,26),
	(225,22,'StellwagenBankNMS_SS_Aug2012','b','cts','ot',NULL,NULL,99,'no',NULL,9,'NOAA',NULL,1,26),
	(226,22,'StellwagenBankNMS_SS_Oct2012','b','cts','ot',NULL,NULL,99,'no',NULL,9,'NOAA',NULL,1,26),
	(227,22,'StellwagenBankNMS_SS_Jan2013','b','cts','ot',NULL,NULL,99,'no',NULL,9,'NOAA',NULL,1,26),
	(228,22,'StellwagenBankNMS_SS_Apr2013','b','cts','ot',NULL,NULL,99,'no',NULL,9,'NOAA',NULL,1,26),
	(229,22,'StellwagenBankNMS_SS_Jun2013','b','cts','ot',NULL,NULL,99,'no',NULL,9,'NOAA',NULL,1,26),
	(230,22,'StellwagenBankNMS_SS_Aug2013','b','cts','ot',NULL,NULL,99,'no',NULL,9,'NOAA',NULL,1,26),
	(231,22,'StellwagenBankNMS_SS_Oct2013','b','cts','ot',NULL,NULL,99,'no',NULL,9,'NOAA',NULL,1,26),
	(232,22,'StellwagenBankNMS_SS_Apr2014','b','cts','ot',NULL,NULL,99,'no',NULL,9,'NOAA',NULL,1,26),
	(233,22,'StellwagenBankNMS_SS_Jun2014','b','cts','ot',NULL,NULL,99,'no',NULL,9,'NOAA',NULL,1,26),
	(234,22,'StellwagenBankNMS_SS_Aug2014','b','cts','ot',NULL,NULL,99,'no',NULL,9,'NOAA',NULL,1,26),
	(235,22,'StellwagenBankNMS_SS_Sep2014','b','cts','ot',NULL,NULL,99,'no',NULL,9,'NOAA',NULL,1,26),
	(236,22,'StellwagenBankNMS_SS_Oct2014','b','cts','ot',NULL,NULL,99,'no',NULL,9,'NOAA',NULL,1,26),
	(237,22,'StellwagenBankNMS_SS_Dec2014','b','cts','ot',NULL,NULL,99,'no',NULL,9,'NOAA',NULL,1,26),
	(238,22,'StellwagenBankNMS_SS_Jun2015','b','cts','ot',NULL,NULL,99,'no',NULL,9,'NOAA',NULL,1,26),
	(239,22,'StellwagenBankNMS_SS_Aug2015','b','cts','ot',NULL,NULL,99,'no',NULL,9,'NOAA',NULL,1,26),
	(240,22,'StellwagenBankNMS_SS_Sep2015','b','cts','ot',NULL,NULL,99,'no',NULL,9,'NOAA',NULL,1,26),
	(241,22,'StellwagenBankNMS_SS_Oct2015','b','cts','ot',NULL,NULL,99,'no',NULL,9,'NOAA',NULL,1,26),
	(242,22,'StellwagenBankNMS_SS_Dec2015','b','cts','ot',NULL,NULL,99,'no',NULL,9,'NOAA',NULL,1,26),
	(243,21,'DeepwaterWindBlockIsland0910_camera','c','cts','ot',NULL,NULL,9,'no',NULL,65,'BOEM,TetraTech,Deepwater Wind RI',53,1,NULL),
	(244,20,'StellwagenBankNMS_WW_2011-10-22','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(245,20,'StellwagenBankNMS_WW_2012-06-17','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(246,20,'StellwagenBankNMS_WW_2012-06-24','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(247,20,'StellwagenBankNMS_WW_2012-07-01','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(248,20,'StellwagenBankNMS_WW_2012-07-08','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(249,20,'StellwagenBankNMS_WW_2012-07-15','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(250,20,'StellwagenBankNMS_WW_2012-08-12','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(251,20,'StellwagenBankNMS_WW_2012-08-19','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(252,20,'StellwagenBankNMS_WW_2012-08-25','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(253,20,'StellwagenBankNMS_WW_2012-08-26','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(254,20,'StellwagenBankNMS_WW_2012-09-01','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(255,20,'StellwagenBankNMS_WW_2012-09-02','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(256,20,'StellwagenBankNMS_WW_2012-09-08','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(257,20,'StellwagenBankNMS_WW_2012-09-09','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(258,20,'StellwagenBankNMS_WW_2012-09-16','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(259,20,'StellwagenBankNMS_WW_2012-09-22','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(260,20,'StellwagenBankNMS_WW_2012-09-30','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(261,20,'StellwagenBankNMS_WW_2012-10-20','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(262,20,'StellwagenBankNMS_WW_2012-10-21','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(263,20,'StellwagenBankNMS_WW_2012-10-27','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(264,20,'StellwagenBankNMS_WW_2013-06-16','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(265,20,'StellwagenBankNMS_WW_2013-06-19','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(266,20,'StellwagenBankNMS_WW_2013-06-23','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(267,20,'StellwagenBankNMS_WW_2013-06-27','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(268,20,'StellwagenBankNMS_WW_2013-06-29','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(269,20,'StellwagenBankNMS_WW_2013-06-30','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(270,20,'StellwagenBankNMS_WW_2013-07-13','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(271,20,'StellwagenBankNMS_WW_2013-07-14','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(272,20,'StellwagenBankNMS_WW_2013-07-20','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(273,20,'StellwagenBankNMS_WW_2013-07-28','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(274,20,'StellwagenBankNMS_WW_2013-08-03','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(275,20,'StellwagenBankNMS_WW_2013-08-04','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(276,20,'StellwagenBankNMS_WW_2013-08-06','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(277,20,'StellwagenBankNMS_WW_2013-08-11','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(278,20,'StellwagenBankNMS_WW_2013-08-17','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(279,20,'StellwagenBankNMS_WW_2013-08-18','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(280,20,'StellwagenBankNMS_WW_2013-08-20','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(281,20,'StellwagenBankNMS_WW_2013-08-24','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(282,20,'StellwagenBankNMS_WW_2013-08-25','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(283,20,'StellwagenBankNMS_WW_2013-08-31','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(284,20,'StellwagenBankNMS_WW_2013-09-04','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(285,20,'StellwagenBankNMS_WW_2013-09-14','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(286,20,'StellwagenBankNMS_WW_2013-09-15','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(287,20,'StellwagenBankNMS_WW_2013-09-29','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(288,20,'StellwagenBankNMS_WW_2013-10-05','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(289,20,'StellwagenBankNMS_WW_2013-10-17','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(290,20,'StellwagenBankNMS_WW_2013-10-26','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(291,20,'StellwagenBankNMS_WW_2013-10-27','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(292,20,'StellwagenBankNMS_WW_2013-11-10','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(293,20,'StellwagenBankNMS_WW_2014-05-02','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(294,20,'StellwagenBankNMS_WW_2014-05-09','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(295,20,'StellwagenBankNMS_WW_2014-05-16','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(296,20,'StellwagenBankNMS_WW_2014-06-08','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(297,20,'StellwagenBankNMS_WW_2014-06-15','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(298,20,'StellwagenBankNMS_WW_2014-06-16','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(299,20,'StellwagenBankNMS_WW_2014-06-21','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(300,20,'StellwagenBankNMS_WW_2014-06-27','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(301,20,'StellwagenBankNMS_WW_2014-06-28','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(302,20,'StellwagenBankNMS_WW_2014-07-10','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(303,20,'StellwagenBankNMS_WW_2014-07-11','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(304,20,'StellwagenBankNMS_WW_2014-07-13','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(305,20,'StellwagenBankNMS_WW_2014-07-18','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(306,20,'StellwagenBankNMS_WW_2014-07-20','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(307,20,'StellwagenBankNMS_WW_2014-07-21','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(308,20,'StellwagenBankNMS_WW_2014-07-26','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(309,20,'StellwagenBankNMS_WW_2014-07-27','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(310,20,'StellwagenBankNMS_WW_2014-08-02','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(311,20,'StellwagenBankNMS_WW_2014-08-03','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(312,20,'StellwagenBankNMS_WW_2014-08-09','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(313,20,'StellwagenBankNMS_WW_2014-08-10','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(314,20,'StellwagenBankNMS_WW_2014-08-16','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(315,20,'StellwagenBankNMS_WW_2014-08-17','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(316,20,'StellwagenBankNMS_WW_2014-08-25','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(317,20,'StellwagenBankNMS_WW_2014-08-30','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(318,20,'StellwagenBankNMS_WW_2014-08-31','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(319,20,'StellwagenBankNMS_WW_2014-09-06','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(320,20,'StellwagenBankNMS_WW_2014-09-13','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(321,20,'StellwagenBankNMS_WW_2014-09-14','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(322,20,'StellwagenBankNMS_WW_2014-09-20','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(323,20,'StellwagenBankNMS_WW_2014-09-28','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(324,20,'StellwagenBankNMS_WW_2014-10-05','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(325,20,'StellwagenBankNMS_WW_2014-10-12','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(326,20,'StellwagenBankNMS_WW_2014-10-18','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(327,20,'StellwagenBankNMS_WW_2014-10-26','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(328,20,'StellwagenBankNMS_WW_2014-10-31','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(329,20,'StellwagenBankNMS_WW_2014-11-08','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(330,20,'StellwagenBankNMS_WW_2014-11-15','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(331,20,'StellwagenBankNMS_WW_2015-04-11','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(332,20,'StellwagenBankNMS_WW_2015-04-26','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(333,20,'StellwagenBankNMS_WW_2015-05-10','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(334,20,'StellwagenBankNMS_WW_2015-05-17','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(335,20,'StellwagenBankNMS_WW_2015-05-24','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(336,20,'StellwagenBankNMS_WW_2015-05-30','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(337,20,'StellwagenBankNMS_WW_2015-05-31','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(338,20,'StellwagenBankNMS_WW_2015-06-07','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(339,20,'StellwagenBankNMS_WW_2015-06-13','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(340,20,'StellwagenBankNMS_WW_2015-06-14','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(341,20,'StellwagenBankNMS_WW_2015-06-20','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(342,20,'StellwagenBankNMS_WW_2015-06-21','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(343,20,'StellwagenBankNMS_WW_2015-06-27','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(344,20,'StellwagenBankNMS_WW_2015-07-05','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(345,20,'StellwagenBankNMS_WW_2015-07-11','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(346,20,'StellwagenBankNMS_WW_2015-07-12','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(347,20,'StellwagenBankNMS_WW_2015-07-18','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(348,20,'StellwagenBankNMS_WW_2015-07-19','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(349,20,'StellwagenBankNMS_WW_2015-07-23','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(350,20,'StellwagenBankNMS_WW_2015-07-25','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(351,20,'StellwagenBankNMS_WW_2015-08-01','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(352,20,'StellwagenBankNMS_WW_2015-08-02','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(353,20,'StellwagenBankNMS_WW_2015-08-08','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(354,20,'StellwagenBankNMS_WW_2015-08-09','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(355,20,'StellwagenBankNMS_WW_2015-08-15','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(356,20,'StellwagenBankNMS_WW_2015-08-22','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(357,20,'StellwagenBankNMS_WW_2015-08-23','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(358,20,'StellwagenBankNMS_WW_2015-08-29','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(359,20,'StellwagenBankNMS_WW_2015-09-06','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(360,20,'StellwagenBankNMS_WW_2015-09-12','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(361,20,'StellwagenBankNMS_WW_2015-09-13','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(362,20,'StellwagenBankNMS_WW_2015-09-19','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(363,20,'StellwagenBankNMS_WW_2015-09-20','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(364,20,'StellwagenBankNMS_WW_2015-09-26','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(365,20,'StellwagenBankNMS_WW_2015-09-27','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(366,20,'StellwagenBankNMS_WW_2015-10-11','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(367,20,'StellwagenBankNMS_WW_2015-10-18','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(368,20,'StellwagenBankNMS_WW_2015-10-24','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(369,20,'StellwagenBankNMS_WW_2015-11-01','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(370,20,'StellwagenBankNMS_WW_2015-11-07','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(371,23,'StellwagenBankNMS_Other_Sept2013','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),--listed as standardized but is in question
	(372,23,'StellwagenBankNMS_Other_2011-08-02','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(373,23,'StellwagenBankNMS_Other_2011-09-15','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(374,23,'StellwagenBankNMS_Other_2011-09-21','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(375,23,'StellwagenBankNMS_Other_2011-10-18','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(376,23,'StellwagenBankNMS_Other_2011-12-30','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(377,23,'StellwagenBankNMS_Other_2012-04-17','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(378,23,'StellwagenBankNMS_Other_2013-07-28','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(379,23,'StellwagenBankNMS_Other_2013-09-04','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(380,23,'StellwagenBankNMS_Other_2014-07-25','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(381,23,'StellwagenBankNMS_Other_2014-07-26','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(382,23,'StellwagenBankNMS_Other_2014-08-09','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1,NULL),
	(383,10,'EcoMonFeb2011','b','cts','ot',300,300,0,'no',NULL,NULL,'NOAA',NULL,1,6),--DEL 1102
	(384,10,'EcoMonJun2011','b','cts','ot',300,300,0,'no',NULL,NULL,'NOAA',NULL,1,6),--DEL 1105
	(385,10,'EcoMonJun2013','b','cts','ot',300,300,0,'no',NULL,16,'NOAA',NULL,1,23),--GU 1302
	(386,10,'EcoMonNov2013','b','cts','ot',300,300,0,'no',NULL,16,'NOAA',NULL,1,23),--GU 1305
	(387,10,'EcoMonMar2014','b','cts','ot',300,300,0,'no',NULL,16,'NOAA',NULL,1,23),--GU 1401
	(388,10,'EcoMonMay2015','b','cts','ot',300,300,0,'no',NULL,16,'NOAA',NULL,1,22),--HB 1502
	(389,10,'EcoMonOct2015','b','cts','ot',300,300,0,'no',NULL,16,'NOAA',NULL,1,23),--GU 1506 
	(390,10,'EcoMonAug2016','b','cts','ot',300,300,0,'no',NULL,16,'NOAA',NULL,1,24),--PC 1607
	(391,10,'EcoMonMay2016','b','cts','ot',300,300,0,'no',NULL,16,'NOAA',NULL,1,23),--GU 1608
	(392,10,'EcoMonOct2016','b','cts','ot',300,300,0,'no',NULL,16,'NOAA',NULL,1,24),--PC 1609 no bird observer 
	(393,10,'EcoMonMay2017_GU1701','b','cts','ot',300,300,0,'no',NULL,16,'NOAA',NULL,1,23),
	(394,10,'EcoMonJune2017_GU1702','b','cts','ot',300,300,0,'no',NULL,16,'NOAA',NULL,1,23),
	(395,1,'AMAPPS_FWS_Aerial_Summer2017','a','cts','ot',400,200,5,'no','no',50,'BOEM,USFWS,NOAA,NAVY',110,1,NULL),
	(173,24,'NYSERDA_OPA_Survey1_Summer2016','c','cts','ot',NULL,NULL,99,'no','no',61,'BOEM,APEM,Normandeau',NULL,1,NULL),
	(398,24,'NYSERDA_OPA_Survey2_Fall2016','c','cts','ot',NULL,NULL,99,'no','no',61,'BOEM,APEM,Normandeau',NULL,1,NULL),
	(399,24,'NYSERDA_OPA_Survey3_Winter2017','c','cts','ot',NULL,NULL,99,'no','no',61,'BOEM,APEM,Normandeau',NULL,1,NULL),
	(400,24,'NYSERDA_OPA_Survey4_Spring2017','c','cts','ot',NULL,NULL,99,'no','no',61,'BOEM,APEM,Normandeau',NULL,1,NULL),
	(401,24,'NYSERDA_WEA_Survey1_Summer2016','c','cts','ot',NULL,NULL,99,'no','no',61,'BOEM,APEM,Normandeau',NULL,1,NULL),
	(402,24,'NYSERDA_WEA_Survey2_Fall2016','c','cts','ot',NULL,NULL,99,'no','no',61,'BOEM,APEM,Normandeau',NULL,1,NULL),
	(403,24,'NYSERDA_WEA_Survey3_Winter2017','c','cts','ot',NULL,NULL,99,'no','no',61,'BOEM,APEM,Normandeau',NULL,1,NULL),
	(404,24,'NYSERDA_WEA_Survey4_Spring2017','c','cts','ot',NULL,NULL,99,'no','no',61,'BOEM,APEM,Normandeau',NULL,1,NULL),
	(405,24,'NYSERDA_APEM_9','c','cts','ot',NULL,NULL,0,'no',NULL,61,'BOEM,APEM,Normandeau',NULL,1,NULL),
	(406,24,'NYSERDA_APEM_10','c','cts','ot',NULL,NULL,0,'no',NULL,61,'BOEM,APEM,Normandeau',NULL,1,NULL),
	(407,24,'NYSERDA_APEM_11','c','cts','ot',NULL,NULL,0,'no',NULL,61,'BOEM,APEM,Normandeau',NULL,1,NULL),
	(408,24,'NYSERDA_APEM_12','c','cts','ot',NULL,NULL,0,'no',NULL,61,'BOEM,APEM,Normandeau',NULL,1,NULL),
	(409,2,'AMAPPS_NOAA/NMFS_NEFSCAerial2010','a','cts','ot',NULL,NULL,0,'no',NULL,NULL,'BOEM,USFWS,NOAA,NAVY',NULL,NULL,NULL),
	(410,2,'AMAPPS_NOAA/NMFS_NEFSCAerial2012','a','cts','ot',NULL,NULL,0,'no',NULL,NULL,'BOEM,USFWS,NOAA,NAVY',NULL,NULL,NULL),
	(411,2,'AMAPPS_NOAA/NMFS_NEFSC_2017','b','cts','ot',300,300,5,'yes','yes',52,'BOEM,USFWS,NOAA,NAVY',NULL,1,NULL),
	(412,10,'EcoMonOct2017_GU1706','b','cts','ot',300,300,0,'no',NULL,16,'NOAA',NULL,1,NULL),
	(413,25,'GOMCES 2014','b','cts','ot',NULL,NULL,0,'no',NULL,80,'USFWS, BRI, MDIFW',8,1,25),
    (414,25,'GOMCES 2015','b','cts','ot',NULL,NULL,0,'no',NULL,80,'USFWS, BRI, MDIFW',8,1,25),
    (415,25,'GOMCES 2016','b','cts','ot',NULL,NULL,0,'no',NULL,80,'USFWS, BRI, MDIFW',8,1,25),
	(416,21,'BIWF_onshore_sea_watch_avian_surveys','f','dth','og',3000,3000,9,'no',NULL,65,'BOEM,TetraTech,Deepwater Wind RI',NULL,1,NULL),
	(396,1,'AMAPPS_FWS_Aerial_summer2018','a','cts','ot',400,200,0,'no','no',50,'BOEM,USFWS,NOAA,NAVY',110,1,NULL),
	(397,1,'AMAPPS_FWS_Aerial_2019','a','cts','ot',400,200,0,'no','no',50,'BOEM,USFWS,NOAA,NAVY',110,1,NULL),
	(417,1,'AMAPPS_FWS_Aerial_fall2018','a','cts','ot',400,200,0,'no','no',50,'BOEM,USFWS,NOAA,NAVY',110,1,NULL);
	--(418,21,'BIWF_offshore_passive_bat_acoustic_surveys','p','cbc','og',30,30,9,'no',NULL,65,'BOEM,TetraTech,Deepwater Wind RI',NULL,1,NULL);
	--(419,21,'BIWF_offshore_active_bat_acoustic_surveys','d','cbc','og',NULL,NULL,9,'no',NULL,65,'BOEM,TetraTech,Deepwater Wind RI',NULL,1,NULL);


--	(,2,'AMAPPS_NOAA/NMFS_NEFSCBoat2018','b','cts','ot',300,300,9,'yes','yes',52,'BOEM,USFWS,NOAA,NAVY',NULL,1,NULL),
--	(,2,'AMAPPS_NOAA/NMFS_NEFSCBoat2019','b','cts','ot',300,300,9,'yes','yes',52,'BOEM,USFWS,NOAA,NAVY',NULL,1,NULL),

-- (dataset_id, parent_project, dataset_name, survey_type_cd, survey_method_cd, dataset_type_cd, whole_survey_width_m, individual_observer_survey_width_m,
--	share_level_id, in_database, pooled_observations, responsible_party,sponsors,planned_speed_knots,version_nb,platform_name_id)

/*  update dataset table */
/*    
update dataset
set
dataset_type_cd = 'go'
where dataset_id in (173,398,399,400, 401,402,403,404)

*/

-- select * from dataset order by share_level_id
-- select * from dataset where parent_project = 24

-- adding summary data 
update dataset
set
dataset_summary = '"Surveys were conducted for
30 minutes at each point, during which time all birds seen or heard were recorded on standardized data
sheets. Binoculars (10x42 millimeters [mm]) and spotting scopes (15–46x60 mm) were used to aid in
sighting birds, and observers used field reference materials to confirm identification(Sibley 2000,
Paulson 2005, Proctor and Lynch 2005, O’Brien et al. 2006). Sea watch surveys focused on the
crepuscular periods of the day: dawn and dusk. During dawn surveys point counts began approximately
one-half hour before sunrise, and during dusk surveys counts ended approximately one-half hour after
the sunset. Points were surveyed during the morning and evening periods at an approximately equal
frequency to avoid potential biases related to survey timing. Information on species, number of
individuals, flight ecology, relative age (adult or juvenile), and behavior (foraging, direct flight, and
perched on the ground or water) were recorded. For birds observed in flight, the vertical flight elevation
above the ground or water was estimated and recorded in the following categories: <10 m (<33 ft), 10–
25 m (33–82 ft), 26–125 m (85–410 ft), 126–200 m (413–656 ft), and >200 m (>656 ft). Bird observations
were recorded in distance increments (bins) similar to those used in the RI Ocean SAMP sea watch
surveys: 0–500 m (0–1,640 ft), 500–1,500 m (1,640–4,921 ft), and 1,500–3,000 m (4,921–9,843 ft); the
maximum distance sampled was 3 km (1.9 mi) offshore, or less, as visibility permitted (Paton, Winiarski
et al. 2010). Weather observations were recorded including ambient temperature, wind speed, wind
direction, sea state (Douglas Sea Scale), and visibility."'
where dataset_id = 416

/*update dataset
set
dataset_summary = '"In addition to the four detectors deployed on Block Island a detector was deployed on each of two
buoys, at a height of 2.5 m (8.2 ft) above mean sea level (AMSL). One detector was deployed on a
weather buoy anchored 5.6 km (3 nm) south of the island, and a second buoy 27.8 km (15 nm) east of
Block Island (Figure 3.3.1). Anabat SD-1 detectors (Titley Electronics, Inc.) were used and weatherized
for the marine environment. Each detector was set up to transmit data via a cellular connection. The
detector received power from the buoy’s internal solar power system. The microphone of the buoy
detector was buffered from the marine environment by a 90 degree sweep section of PVC piping, with a
small drain hole in the bottom (Appendix A). The PVC tube was intended to prevent sea spray from
directly contacting the microphone’s elements. The PVC tubing acted as a deflector for potential call
sequences to be recorded by the unit, similar to the deflector plates used on the onshore passive
acoustic setups (Appendix A). Sensitivity of the microphone was tested prior to deployment using a bat
chirper (Tony Massena, Nevada) which produces a constant 40 kHz tone. The detectors were calibrated
prior to deployment to ensure that bat calls would be detected within a maximum range of 30 m (98 ft)
at 40 kHz"'
where dataset_id = 417*/

--create revisions table
CREATE TABLE lu_revision_details (
	dataset_id smallint not null,
	version_nb tinyint not null,
	revision_date date not null,
	revision_details nvarchar(1000) not null,
	Primary Key (dataset_id, version_nb),
	foreign key (dataset_id) references dataset(dataset_id)
);
GO

INSERT INTO lu_revision_details(dataset_id,version_nb,revision_date,revision_details)
	VALUES(135,2,CAST('2017-07-12' AS DATE),'Changed date from 1/11/2011 to 1/11/2012 and transect id from 2011-01-11_NJM to 2012-01-11_NJM. This includes the observation table (records :), track table (records :) and tranesct table (record 122117).')
	--(,2,CAST('' AS DATE),'NEED TO CHANGE NOAA AMAPPS 2015 LEG TO TRANSECT IDS, in Email to Arliss')
-- 
-- select * from lu_revision_details
--

-- create transect table
CREATE TABLE transect (
	transect_id int not null,
	dataset_id smallint not null,
	source_transect_id nvarchar(50) null,
	start_dt date null,
	start_tm time null,
	--start_lat numeric null,
	--start_lon numeric null, 
	end_dt date null,
	end_tm time null,
	--end_lat numeric null,
	--end_lon numeric null,
	start_seconds_from_midnight numeric null,
	end_seconds_from_midnight numeric null,
	observer_tx nvarchar(20) null,
	observer_position nvarchar(20) null,
	visibility_tx nvarchar(50) null,
	weather_tx nvarchar(50) null,
	seastate_beaufort_nb tinyint null,
	wind_dir_tx nvarchar(50) null,
	seasurface_tempc_nb numeric null,
	heading_tx nvarchar(20) null,
	altitude_m smallint null,
	vehicle_name nvarchar(50) null, 
	geom_line nvarchar(MAX) null,
	comments nvarchar(1000) null,
	PRIMARY KEY(transect_id),
	FOREIGN KEY(dataset_id) REFERENCES dataset(dataset_id),
	FOREIGN KEY(seastate_beaufort_nb) REFERENCES lu_beaufort(beaufort_id)
);
--

-- create observation table
CREATE TABLE observation (
	observation_id int not null,
	source_obs_id int null, 
	dataset_id smallint not null,
	transect_id int null, 
	obs_dt date null,
	obs_tm time null,
	--obs_lat numeric null,
	--obs_lon numeric null,
	original_species_tx nvarchar(50) null,
	spp_cd nvarchar(4) not null,
	obs_count_intrans_nb smallint null,
	obs_count_general_nb smallint null, --should be not null, need to check 
	observer_tx nvarchar(20) null,
	observer_position nvarchar(20) null,
	seconds_from_midnight numeric null,
	original_age_tx nvarchar(50) null,
	age_id tinyint null,
	plumage_tx nvarchar(50) null,
	original_behavior_tx nvarchar(100) null,
	behavior_id tinyint null,
	original_sex_tx varchar(50) null,
	sex_id tinyint null,
	travel_direction_tx nvarchar(50) null,
	heading_tx nvarchar(50) null,
	flight_height_tx nvarchar(50) null,
	distance_to_animal_tx nvarchar(50) null,
	angle_from_observer_nb tinyint null,
	associations_tx nvarchar(50) null,
	visibility_tx nvarchar(50) null,
	seastate_beaufort_nb tinyint null,
	wind_speed_tx nvarchar(50) null,
	wind_dir_tx nvarchar(50) null,
	--seasurface_tempc_nb numeric null,
	cloud_cover_tx nvarchar(50) null,
	--salinity_ppt_nb numeric null,
	wave_height_tx nvarchar(50) null,
	camera_reel nvarchar(50) null,
	observer_confidence nvarchar(50) null,
	--boem_lease_block_id smallint null,
	observer_comments nvarchar(250) null,
	geom_line nvarchar(MAX) null,
	admin_notes nvarchar(250) null,
	PRIMARY KEY(observation_id),
	FOREIGN KEY(dataset_id) REFERENCES dataset(dataset_id),
	FOREIGN KEY(seastate_beaufort_nb) REFERENCES lu_beaufort(beaufort_id),
	FOREIGN KEY(spp_cd) REFERENCES lu_species(spp_cd),
	FOREIGN KEY(transect_id) REFERENCES transect(transect_id),
	FOREIGN KEY(behavior_id) REFERENCES lu_behaviors(behavior_id),
	FOREIGN KEY(age_id) REFERENCES lu_age(age_id),
	FOREIGN KEY(sex_id) REFERENCES lu_sex(sex_id),
	--FOREIGN KEY(boem_lease_block_id) REFERENCES lu_boem_lease_blocks(boem_lease_block_id)
);
--

-- create track table
CREATE TABLE track (
	track_id int not null,
	dataset_id smallint not null,
	transect_id int null, 
	track_dt date null,
	track_tm time null,
	--track_lat numeric null,
	--track_lon numeric null,
	point_type nchar(10) null,
	source_track_id nvarchar(50) null,
	seconds_from_midnight_nb numeric null,
	geom_line nvarchar(MAX) null,
	comments nvarchar(50) null,
	PRIMARY KEY(track_id),
	FOREIGN KEY(transect_id) REFERENCES transect(transect_id),
	FOREIGN KEY(dataset_id) REFERENCES dataset(dataset_id)
);
--

------------------------------
-- create extra info tables --
------------------------------

--create url, citations, and reports table
CREATE TABLE links_and_literature (
	id smallint not null,
	dataset_id smallint not null,
	data_url nvarchar(2083) null,
	report nvarchar(2083) null,
	data_citation nvarchar(2000) null,
	publications nvarchar(2000) null,
	publication_url nvarchar(2000) null,
	publication_DOI nvarchar(2000) null,
	PRIMARY KEY(id),
	FOREIGN KEY(dataset_id) REFERENCES dataset(dataset_id)
);

INSERT INTO links_and_literature(
	id, dataset_id, data_url, report, data_citation, publications, publication_url, publication_DOI)
	VALUES
	(1,15,'http://seamap.env.duke.edu/datasets/detail/322',NULL,'Hyrenbach, D. 2011. Hatteras Eddy Cruise 2004. Data downloaded from OBIS-SEAMAP (http://seamap.env.duke.edu/dataset/322) on yyyy-mm-dd.',NULL,NULL,NULL),
	(2,24,'http://seamap.env.duke.edu/datasets/detail/310',NULL,'Hyrenbach, D. and H. Whitehead. 2008. Sargasso 2004 - Seabirds . Data downloaded from OBIS-SEAMAP (http://seamap.env.duke.edu/dataset/310) on yyyy-mm-dd',NULL,NULL,NULL),
	(3,115,NULL,'http://www.briloon.org/uploads/BRI_Documents/Wildlife_and_Renewable_Energy/MABS%20Project%20Chapter%203%20-%20Connelly%20et%20al%202015.pdf',NULL,NULL,NULL,NULL),
	(4,148,NULL,'http://www.briloon.org/uploads/BRI_Documents/Wildlife_and_Renewable_Energy/MABS%20Project%20Chapter%203%20-%20Connelly%20et%20al%202015.pdf',NULL,NULL,NULL,NULL),
	(5,168,NULL,'http://www.briloon.org/uploads/BRI_Documents/Wildlife_and_Renewable_Energy/MABS%20Project%20Chapter%203%20-%20Connelly%20et%20al%202015.pdf',NULL,NULL,NULL,NULL),
	(6,117,NULL,'http://www.nefsc.noaa.gov/psb/AMAPPS/docs/NMFS_AMAPPS_2011_annual_report_final_BOEM.pdf',NULL,NULL,NULL,NULL),
	(7,143,NULL,'https://www.boem.gov/ESPIS/5/5272.pdf',NULL,NULL,NULL,NULL),
	(8,144,NULL,'https://www.boem.gov/ESPIS/5/5272.pdf',NULL,NULL,NULL,NULL),
	(9,169,NULL,'https://www.boem.gov/ESPIS/5/5272.pdf',NULL,NULL,NULL,NULL),
	(10,91,NULL,'http://www.nj.gov/dep/dsr/ocean-wind/report.htm'' AND ''http://www.nj.gov/dep/dsr/ocean-wind/final-volume-1.pdf',NULL,NULL,NULL,NULL),
	(11,113,NULL,'http://seaduckjv.org/pdf/studies/pr109.pdf',NULL,NULL,NULL,NULL),
	(12,29,'http://seamap.env.duke.edu/dataset/3','Southeast Fisheries Science Center, Marine Fisheries Service, NOAA. 1992. OREGON II Cruise. Cruise report. 92-01 (198).','Garrison, L. 2013. SEFSC Atlantic surveys 1992. Data downloaded from OBIS-SEAMAP (http://seamap.env.duke.edu/dataset/3) on yyyy-mm-dd.',NULL,NULL,NULL),
	(13,30,'http://seamap.env.duke.edu/dataset/1','Southeast Fisheries Science Center, Marine Fisheries Service, NOAA. 1998. Cruise Results: Summer Atlantic Ocean Marine Mammal Survey: NOAA Ship Relentless Cruise. Cruise report. RS 98-01 (3)','Garrison, L. 2013. SEFSC Atlantic surveys, 1998 (3). Data downloaded from OBIS-SEAMAP (http://seamap.env.duke.edu/dataset/1) on yyyy-mm-dd.',NULL,NULL,NULL),
	(14,31,'http://seamap.env.duke.edu/dataset/5 ; https://gcmd.nasa.gov/KeywordSearch/Metadata.do?Portal=idn_ceos&KeywordPath=%5BKeyword%3D%27shore+birds%27%5D&OrigMetadataNode=GCMD&EntryId=seamap5&MetadataView=Full&MetadataType=0&lbnode=mdlb2','Southeast Fisheries Science Center, Marine Fisheries Service, NOAA. 1999. Cruise Results; Summer Atlantic Ocean Marine Mammal Survey; NOAA Ship Oregon II Cruise. Cruise report. OT 99-05 (236)','Garrison, L. 2013. SEFSC Atlantic surveys 1999. Data downloaded from OBIS-SEAMAP (http://seamap.env.duke.edu/dataset/5) on yyyy-mm-dd.',NULL,NULL,NULL),
	(15,92,'http://seamap.env.duke.edu/datasets/detail/280',NULL,'Hyrenbach, D., F. Huettmann and J. Chardine. 2012. PIROP Northwest Atlantic 1965-1992. Data downloaded from OBIS-SEAMAP (http://seamap.env.duke.edu/dataset/280) on yyyy-mm-dd.',NULL,NULL,NULL),
	(16,7,'http://seamap.env.duke.edu/datasets/detail/280','http://www.whoi.edu/science/PO/hatterasfronts/marinemammal.html','Hyrenbach, D., F. Huettmann and J. Chardine. 2012. PIROP Northwest Atlantic 1965-1992. Data downloaded from OBIS-SEAMAP (http://seamap.env.duke.edu/dataset/280) on yyyy-mm-dd.',NULL,NULL,NULL),
	(17,80,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2010/MAY_ECOMON_DEL1004/CRUISE_REPORT_2010004DE.pdf',NULL,NULL,NULL,NULL),
	(18,81,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2010/NOV_ECOMON_DEL1012/CRUISE_REPORT_2010012DE.pdf',NULL,NULL,NULL,NULL),
	(19,42,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2009/AUG_ECOMON_DEL0909/CRUISE_REPORT_2009009DE.pdf',NULL,NULL,NULL,NULL),
	(20,38,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2009/JAN_ECOMON_DEL0902/CRUISE_REPORT_2009002DEL.pdf',NULL,NULL,NULL,NULL),
	(21,39,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2009/MAY_ECOMON_DEL0905/CRUISE_REPORT_2009005DE.pdf',NULL,NULL,NULL,NULL),
	(22,76,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2010/NOV_ECOMON_DEL1012/CRUISE_REPORT_2010012DE.pdf',NULL,NULL,NULL,NULL),
	(23,77,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2008/AUG_ECOMON_DEL0808/CRUISE_REPORT_2008008DE.pdf',NULL,NULL,NULL,NULL),
	(24,171,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2013/FEB_ECOMON_PC1301/CRUISE_REPORT_2013001PC.pdf',NULL,NULL,NULL,NULL),
	(25,131,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2012/FEB_ECOMON_DEL1202/CRUISE_REPORT_2012002DE.pdf',NULL,NULL,NULL,NULL),
	(26,82,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2010/AUG_ECOMON_DEL1009/CRUISE_REPORT_2010009DE.pdf',NULL,NULL,NULL,NULL),
	(27,79,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2010/JAN_ECOMON_DEL1001/CRUISE_REPORT_2010001DE.pdf',NULL,NULL,NULL,NULL),
	(28,33,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2007/MAY_ECOMON_DEL0706/CRUISE_REPORT_2007006DE.pdf',NULL,NULL,NULL,NULL),
	(29,74,NULL,'https://gcmd.gsfc.nasa.gov/search/Metadata.do?from=getdif&subset=GCMD&entry=%5BGCMD%5DGoMA-Platts_Bank_Aerial_Survey#metadata',NULL,NULL,NULL,NULL),
	(30,89,NULL,NULL,NULL,'Kristopher J. Winiarski, M. Louise Burt, Eric Rexstad, David L. Miller, Carol L. Trocki, Peter W. C.Paton, and Scott R. McWilliams. 2014. Integrating aerial and ship surveys of marine birds into a combineddensity surface model: A case study of wintering Common Loons. The Condor. 116(2):149-161','https://www.researchgate.net/publication/260553628_Integrating_aerial_and_ship_surveys_of_marine_birds_into_a_combined_density_surface_model_A_case_study_of_wintering_Common_Loons','10.1650/CONDOR-13-085.1'),
	(31,90,NULL,NULL,NULL,'Kristopher J. Winiarski, M. Louise Burt, Eric Rexstad, David L. Miller, Carol L. Trocki, Peter W. C.Paton, and Scott R. McWilliams. 2014. Integrating aerial and ship surveys of marine birds into a combineddensity surface model: A case study of wintering Common Loons. The Condor. 116(2):149-161','https://www.researchgate.net/publication/260553628_Integrating_aerial_and_ship_surveys_of_marine_birds_into_a_combined_density_surface_model_A_case_study_of_wintering_Common_Loons','10.1650/CONDOR-13-085.1'),
 	(32,390 ,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2016/AUG_ECOMON_PC1607/CRUISE_REPORT_2016007PC.pdf',NULL,NULL,NULL,NULL),
 	(33,391 ,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2016/MAY_ECOMON_GU1608/CRUISE_REPORT_2016008GU.pdf',NULL,NULL,NULL,NULL),
 	(34,388 ,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2015/MAY_ECOMON_HB1502/CRUISE_REPORT_2015002HB.pdf',NULL,NULL,NULL,NULL),
 	(35,389 ,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2015/OCT_ECOMON_GU1506/CRUISE_REPORT_2015006GU.pdf',NULL,NULL,NULL,NULL),
 	(36,387 ,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2014/MAR_ECOMON_GU1401/CRUISE_REPORT_2014001GU.pdf',NULL,NULL,NULL,NULL),
 	(37,385 ,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2013/JUN_ECOMON_GU1302/CRUISE_REPORT_2013002GU.pdf',NULL,NULL,NULL,NULL),
 	(38,386 ,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2013/NOV_ECOMON_GU1305/CRUISE_REPORT_2013005GU.pdf',NULL,NULL,NULL,NULL),
 	(39,383 ,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2011/FEB_ECOMON_DEL1102/CRUISE_REPORT_2011002DE.pdf',NULL,NULL,NULL,NULL),
 	(40,384 ,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2011/JUN_ECOMON_DEL1105/CRUISE_REPORT_2011005DE.pdf',NULL,NULL,NULL,NULL),
	(41,393 ,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2017/FEB_ECOMON_HB1701/CRUISE_REPORT_2017001HB.pdf',NULL,NULL,NULL,NULL),
	(42,173,'https://remote.normandeau.com/login.php','https://remote.normandeau.com/docs/Summary%20of%20Summer%202016%20Survey%201.pdf',NULL,NULL,NULL,NULL),
	(43,398,'https://remote.normandeau.com/login.php','https://remote.normandeau.com/docs/NYSERDA-Fall%202016%20Survey2_Summary.pdf',NULL,NULL,NULL,NULL),
	(44,399,'https://remote.normandeau.com/login.php','https://remote.normandeau.com/docs/NYSERDA%20Winter%202017%20-%20Survey%20Summary%20Report.pdf',NULL,NULL,NULL,NULL),
	(45,400,'https://remote.normandeau.com/login.php','https://remote.normandeau.com/docs/NYSERDA%20Spring%202017%20-%20Survey%20Summary%20Report.pdf',NULL,NULL,NULL,NULL),
	(46,401,'https://remote.normandeau.com/login.php','https://remote.normandeau.com/docs/NYSERDA%20Summer%202017%20-%20Survey%20Summary%20Report.pdf',NULL,NULL,NULL,NULL),
	(47,119,'http://iobis.org/explore/#/dataset/2656','http://ipt.iobis.org/obiscanada/resource?r=cws_eastcoastseabirdsatc',NULL,NULL,'http://iobis.org/explore/#/dataset/2656',NULL),
	(48,174,NULL,'https://www.nefsc.noaa.gov/psb/AMAPPS/docs/Annual%20Report%20of%202016%20AMAPPS_final.pdf',NULL,NULL,NULL,NULL),
	(49,160,NULL,'https://www.nefsc.noaa.gov/psb/AMAPPS/docs/NMFS_AMAPPS_2015_annual_report_Final.pdf',NULL,NULL,NULL,NULL),
	(50,149,NULL,'https://www.nefsc.noaa.gov/psb/AMAPPS/docs/NMFS_AMAPPS_2014_annual_report_Final.pdf',NULL,NULL,NULL,NULL),
	(51,116,NULL,'https://www.nefsc.noaa.gov/psb/AMAPPS/docs/NMFS_AMAPPS_2013_annual_report_FINAL3.pdf',NULL,NULL,NULL,NULL),
	(52,409,NULL,'https://www.nefsc.noaa.gov/psb/AMAPPS/docs/Final_2010AnnualReportAMAPPS_19Apr2011.pdf',NULL,NULL,NULL,NULL),
	(53,410,NULL,'https://www.nefsc.noaa.gov/psb/AMAPPS/docs/NMFS_AMAPPS_2012_annual_report_FINAL.pdf',NULL,NULL,NULL,NULL);
--  (54,4__,NULL,'https://www.researchgate.net/publication/324274508_THE_GULF_OF_MAINE_COASTAL_ECOSYSTEM_SURVEY_PROJECT_END_REPORT',NULL,NULL,NULL,'10.13140/RG.2.2.14932.71045')
--  (id, dataset_id, data_url, report, data_citation, publications, publication_url, publication_DOI)

/*  update links_and_literature script template*/
/*  update links_and_literature
	set
	report = 'http://ipt.iobis.org/obiscanada/resource?r=cws_eastcoastseabirdsatc'
	publication_url = 'http://iobis.org/explore/#/dataset/2656'
	where dataset_id = 119
*/

-- select * from links_and_literature

/* notes
	-ECOMON Nov 2014 no birds in report? combined with Herring Acoustic https://www.nefsc.noaa.gov/HydroAtlas/2014/NOV_ECOMON_PC1405/CRUISE_REPORT_2014005PC.pdf
	-ECOMON Dec 2011 we might have this data listed as Nov? Tim White on boat. Not the same as Nov 2011, finish stations not hit in Nov https://www.nefsc.noaa.gov/HydroAtlas/2011/DEC_ECOMON_DEL1110/CRUISE_REPORT_2011010DE.pdf
*/

update dataset
set
  data_url = links_and_literature.data_url, 
  report = links_and_literature.report, 
  data_citation = links_and_literature.data_citation, 
  publications = links_and_literature.publications, 
  publication_url = links_and_literature.publication_url, 
  publication_DOI = links_and_literature.publication_DOI
from dataset2 join links_and_literature on links_and_literature.dataset_id = dataset2.dataset_id
-- select * from dataset2
drop table links_and_literature

--create and populate progress_table table
CREATE TABLE progress_table (
	dataset_id smallint not null,
	dataset_name nvarchar(50) not null,
	share_level_id tinyint not null,
	priority_ranking tinyint null, --1:3 used for NOAA ranking but could rank another way
	action_required_or_taken nvarchar(50) not null,
	date_of_action date null,
	who_will_act nvarchar(50) not null,
	data_acquired bit not null,
	metadata_acquired bit not null,
	report_acquired bit not null,
	additional_info nvarchar(500) null,
	PRIMARY KEY(dataset_id),
	FOREIGN KEY(dataset_id) REFERENCES dataset(dataset_id)
);
GO
--
-- select * from progress_table
INSERT INTO progress_table(
	dataset_id, 
	share_level_id, 
	dataset_name, 
	action_required_or_taken, 
	date_of_action, 
	who_will_act, 
	data_acquired, 
	metadata_acquired, 
	report_acquired, 
	additional_info)
	VALUES
 	(92,7,'PIROP','need to investigate',NULL,'KC',0,0,0,'Apparently already in database but across several other surveys, need to figure out which'),
 	(93,0,'SEANET','need to investigate',NULL,'KC',0,0,0,'Not sure that we actually want this in here'),
	(96,0,'NantucketShoals1998','need to investigate',NULL,'TW',0,0,0,NULL),
	(97,0,'DEandChesBaysUSFWS1190','need to investigate',NULL,'MTJ/KC',0,0,0,NULL),
	(100,0,'AtlanticFlywaySeaducks','need to investigate',NULL,'MTJ/KC',0,0,0,NULL),
	(101,0,'DUMLOnslowBay2007','requested',CAST('2017-10-18' as date),'AW',0,0,0,'data provider on materinty leave, will contact again in a few months'),
	(106,0,'WaterfowlUSFWS2001','need to investigate',NULL,'MTJ/KC',0,0,0,NULL),
	(163,0,'RoyalSociety','need to investigate',NULL,'TW',0,0,0,NULL),
	(166,0,'BarHarborWW09','requested multiple times',CAST('2017-10-17' as date),'KC',0,0,0,NULL),
	(167,0,'BarHarborWW010','requested multiple times',CAST('2017-10-17' as date),'KC',0,0,0,NULL),
	(169,99,'BOEMHighDef_NC2011Camera','need to finish QA/QC',NULL,'KC',1,0,1,'There were issues with the gps and time'),
	(175,9,'DeepwaterWindBlockIsland_boat_Nov09a','QA/QC started',NULL,'KC',1,0,0,NULL),
	(205,9,'DeepwaterWindBlockIsland_boat_Nov09b','QA/QC started',NULL,'KC',1,0,0,NULL),
	(206,9,'DeepwaterWindBlockIsland_boat_Dec10a','QA/QC started',NULL,'KC',1,0,0,NULL),
	(207,9,'DeepwaterWindBlockIsland_boat_Dec10b','QA/QC started',NULL,'KC',1,0,0,NULL),
	(208,9,'DeepwaterWindBlockIsland_boat_Jan10a','QA/QC started',NULL,'KC',1,0,0,NULL),
	(209,9,'DeepwaterWindBlockIsland_boat_Jan10b','QA/QC started',NULL,'KC',1,0,0,NULL),
	(210,9,'DeepwaterWindBlockIsland_boat_Feb10a','QA/QC started',NULL,'KC',1,0,0,NULL),
	(211,9,'DeepwaterWindBlockIsland_boat_Feb10b','QA/QC started',NULL,'KC',1,0,0,NULL),
	(212,9,'DeepwaterWindBlockIsland_boat_Mar10a','QA/QC started',NULL,'KC',1,0,0,NULL),
	(213,9,'DeepwaterWindBlockIsland_boat_Mar10b','QA/QC started',NULL,'KC',1,0,0,NULL),
	(214,9,'DeepwaterWindBlockIsland_boat_Apr10a','QA/QC started',NULL,'KC',1,0,0,NULL),
	(215,9,'DeepwaterWindBlockIsland_boat_Apr10b','QA/QC started',NULL,'KC',1,0,0,NULL),
	(216,9,'DeepwaterWindBlockIsland_boat_May10a','QA/QC started',NULL,'KC',1,0,0,NULL),
	(217,9,'DeepwaterWindBlockIsland_boat_May10b','QA/QC started',NULL,'KC',1,0,0,NULL),
	(218,9,'DeepwaterWindBlockIsland_boat_Jun10a','QA/QC started',NULL,'KC',1,0,0,NULL),
 	(219,9,'DeepwaterWindBlockIsland_boat_Jun10b','QA/QC started',NULL,'KC',1,0,0,NULL),
 	(220,9,'DeepwaterWindBlockIsland_boat_Aug11a','need to request',NULL,'KC',0,0,0,NULL),
 	(221,9,'DeepwaterWindBlockIsland_boat_Aug11b','need to request',NULL,'KC',0,0,0,NULL),
 	(222,9,'DeepwaterWindBlockIsland_boat_Sep11a','need to request',NULL,'KC',0,0,0,NULL),
	(223,9,'DeepwaterWindBlockIsland_boat_Sep11b','need to request',NULL,'KC',0,0,0,NULL),
	(387,0,'EcoMonMar2014','need to request',NULL,'TW/KC',0,0,1,'In contact with TW and AW about this'),
	(389,0,'EcoMonOct2015','need to request',NULL,'TW/KC',0,0,1,'In contact with TW and AW about this'),
	(388,0,'EcoMonMay2015','need to request',NULL,'TW/KC',0,0,1,'In contact with TW and AW about this'),
	(391,0,'EcoMonMay2016','need to request',NULL,'TW/KC',0,0,1,'In contact with TW and AW about this'),
	(390,0,'EcoMonAug2016','need to request',NULL,'TW/KC',0,0,1,'In contact with TW and AW about this'),
	(393,0,'EcoMonFeb2017','need to request',NULL,'TW/KC',0,0,1,'In contact with TW and AW about this'),
	(385,0,'EcoMonJun2013','need to request',NULL,'TW/KC',0,0,1,'In contact with TW and AW about this'),
	(386,0,'EcoMonNov2013','need to request',NULL,'TW/KC',0,0,1,'In contact with TW and AW about this'),
	(383,0,'EcoMonFeb2011','need to request',NULL,'TW/KC',0,0,1,'In contact with TW and AW about this'),
	(384,0,'EcoMonJun2011','need to request',NULL,'TW/KC',0,0,1,'In contact with TW and AW about this'),
	--(173,0,'NYSERDA_APEM_1','requested again',CAST('2018-05-01' as date),'KC',1,0,1,'working on details with provider'),
	--(398,0,'NYSERDA_APEM_2','requested again',CAST('2018-05-01' as date),'KC',1,0,1,'working on details with provider'),
	--(399,0,'NYSERDA_APEM_3','requested again',CAST('2018-05-01' as date),'KC',1,0,1,'working on details with provider'),
	--(400,0,'NYSERDA_APEM_4','requested again',CAST('2018-05-01' as date),'KC',1,0,1,'working on details with provider'),
	--(401,0,'NYSERDA_APEM_5','requested again',CAST('2018-05-01' as date),'KC',1,0,1,'working on details with provider'),
	(243,9,'DeepwaterWindBlockIsland0910_camera','needs QA/QC',NULL,'KC',1,0,0,'this will need reformating'),
    (119,9,'ECSAS','Data downloaded from OBIS, needs effort data',NULL,'KC',1,1,0,'Arliss has full dataset'),
	(413,0,'GOMCES','requested',CAST('2018-05-01' as date),'KC',0,0,1,NULL),
	(414,0,'GOMCES','requested',CAST('2018-05-01' as date),'KC',0,0,1,NULL),	
	(415,0,'GOMCES','requested',CAST('2018-05-01' as date),'KC',0,0,1,NULL);
	--(416,9,'BIWF_onshore_sea_watch_avian_surveys','needs QA/QC',NULL,'KC',1,0,0,'this will need reformating'),

--  dataset_id, share_level_id, dataset_name, action_required_or_taken, date_of_action, who_will_act, 
--  data_acquired, metadata_acquired, report_acquired, additional_info)

/* update progress table script template */  	
/*	update progress_table
  	set 
 	date_of_action=CAST('2018-01-16' as date)
 	where dataset_id in (173,398,399,400,401)
*/

/*
-- remove dataset that was uploaded
delete from progress_table
where dataset_id = 172
*/


/* select progress table script template */ 
--  select * from progress_table order by dataset_name

--create boem lease block table
CREATE TABLE boem_lease_blocks (
	prot_nb nvarchar(20) not null,
 	block_nb nvarchar(20) not null,
	geom_line nvarchar(MAX) not null,
	Primary Key (prot_nb,block_nb)
);
--

-- create data request table
CREATE TABLE requests (
	request_id smallint not null,
	request_type nvarchar(10) not null, 
	requester smallint not null,
	request_info nvarchar(1000) not null, 
	date_requested date not null,
	request_status nvarchar(20) not null, --"filled","not filled","partially filled"
	date_filled date null,
	additional_notes nvarchar(1000) null,
	PRIMARY KEY(request_id),
	FOREIGN KEY(requester) REFERENCES lu_people([user_id])
);
GO

INSERT INTO requests(
	request_id,request_type,requester,request_info,date_requested,
	request_status,date_filled,additional_notes)
	VALUES 
	(1,'data',68,'Segmentation product of all datasets used in Phase 1 of NOAA modeling and additional data for phase 2, see share google spreadsheet for details',
		CAST('2014-01-01' AS DATE),'filled',CAST('2017-04-04' AS DATE),
		'NOAA will need additional datasets to quality control their model in late 2017'),
	(2,'data',67,'Double Crested Cormorants (DCCO) for all of the East Coast, but mostly interested in NC',
		CAST('2016-09-27' AS DATE),'partially filled',CAST('2017-01-25' AS DATE),
		'should requery and resend once all the datasets are in sql server, we only sent old data'),
	(3,'data',69,'all shareable data to go into AKN',CAST('2016-05-12' AS DATE),'partially filled',CAST('2016-10-28' AS DATE),
		'effort and observation information for the old data was sent. More discussion needs to happen with how these data go into AKN. They also need the transect table'),
	(4,'data',70,'Common Loon (COLO) between June 15-Aug 15, years 1910- present',CAST('2016-05-10' AS DATE),
		'not filled',NULL,NULL),
	(5,'data',71,'Razorbills (RAZO), looking for any counts from Maine to Florida at sea for winter 2012-13',
		CAST('2016-04-10' AS DATE),'not filled',NULL,NULL),
	(6,'data',3,'MassCEC',CAST('2017-06-29' AS DATE),'filled',CAST('2017-06-29' AS DATE),NULL),
	(7,'data',50,'All FWS AMAPPS and Seaduck data',CAST('2017-07-12' AS DATE),'filled',CAST('2017-07-17' AS DATE),'This is for an R5 GIS exercise'),
	(8,'data',62,'Segmented NOAA phase 2 product',CAST('2017-07-5' AS DATE),'filled',CAST('2017-07-5' AS DATE),NULL),
	(9,'data',3,'MassCEC',CAST('2017-06-29' AS DATE),'filled',CAST('2017-06-29' AS DATE),'requested an update for another project, version 2 of data'),
	(10,'service',62,'service request to segment EcoMon data not yet submitted to us',CAST('2017-09-14' AS DATE),'filled',CAST('2017-07-5' AS DATE),NULL),
	(11,'data',72, 'Ecological Services BCPE data', CAST('2017-8-15' AS DATE), 'filled', CAST('2017-8-25' AS DATE), NULL),
	(12,'service',72, 'Ecological Services analysis for BCPE data', CAST('2017-8-15' AS DATE), 'filled', CAST('2017-9-15' AS DATE), NULL),
	(13,'data',73, 'AKN request, data and information', CAST('2017-7-28' AS DATE), 'patially filled',NULL, 'back and forth with Rob on details and info'),
	(14,'data',59,'official survey name for each dataset listed in the source_dataset_id column', CAST('2017-09-8' AS DATE), 'filled', CAST('2017-09-11' AS DATE), NULL),
	(15,'service',74,'summary of species and surveys within the new seamount & canyon marine national monuments - request from refuges, Caleb relayed', CAST('2017-11-20' AS DATE), 'filled', CAST('2017-11-29' AS DATE), NULL),
	(16,'service',75,'NWASC boundaries', CAST('2017-11-20' AS DATE), 'filled', CAST('2017-11-29' AS DATE), 'Meghan is looking to create a polygon for pulling AKN data for ECOS for Atlantic birds'),
	(17,'service', 76 ,'Bug data summary for a RI reporter', CAST('2017-12-20' AS DATE),'not filled', NULL, NULL),
	(18,'data',3,'all tern data', CAST('2017-12-04' AS DATE),'filled', CAST('2017-12-08' AS DATE), NULL),
	(19,'data',77,'all landbird data', CAST('2018-01-08' AS DATE),'filled', CAST('2018-01-08' AS DATE), NULL),
	(20,'data',3,'all RISAMP boat data', CAST('2018-01-10' AS DATE),'filled', CAST('2018-01-10' AS DATE), NULL),
	(21,'data',78,'all metadata on surveys',CAST('2018-01-16' AS DATE), 'not filled',NULL,NULL),
	(22,'data',76,'all birds 3 miles out of Woods Hole in Jan-Feb.',CAST('2018-02-02' AS DATE), 'filled',CAST('2018-02-02' AS DATE),NULL),
	(23,'data',79,'all BCPE geospatial data',CAST('2018-02-22' AS DATE),'filled',CAST('2018-02-26' AS DATE),NULL),
	(24,'service',79,'all BCPE data summarized',CAST('2018-02-22' AS DATE),'filled',CAST('2018-02-26' AS DATE),NULL),
	(25,'data',76,'all listed species for ES presentation',CAST('2018-02-22' AS DATE),'not filled',NULL,NULL),
	(26,'data',60,'flight heights for shorebirds',CAST('2018-04-12' AS DATE),'filled',CAST('2018-04-13' AS DATE),NULL),
	(27,'data',60,'make boxplot for shorebird flight heights',CAST('2018-04-12' AS DATE),'filled',CAST('2018-04-13' AS DATE),NULL),
	(28,'data',65,'all effort data',CAST('2018-04-30' AS DATE),'not filled',NULL,NULL),
	(29,'data',77,'redo landbird obs, add dataset info',CAST('2018-05-10' AS DATE),'not filled',NULL,NULL),
	(30,'service',81,'AMAPPS winter 2014 DCCO',CAST('2018-06-14' AS DATE),'filled',CAST('2018-06-14' AS DATE),NULL),
	(31,'data',60,'update boxplot for shorebird flight heights',CAST('2018-06-15' AS DATE),'filled',CAST('2018-06-18' AS DATE),'add n='),
	(32,'data',62,'copy of the species table',CAST('2018-06-15' AS DATE),'filled',CAST('2018-06-15' AS DATE),NULL);

-- example: (id, type, person, description, CAST('req. date' AS DATE), status, CAST('date filled' AS DATE), notes);
/*  update data_requests script template */  	
/*	update requests 
	set date_filled = CAST('2017-07-17' AS DATE), 
	request_status = 'filled'  
	where request_id = 7

	update requests 
	set additional_notes = NULL
	where request_id = 32
*/

/*  look up people who need to be contacted for a project */ 
/*  select * from requests 
	join lu_people 
	on requester = user_id;
*/
