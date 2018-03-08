SppCp_Fix = function(old_obs) {


old_obs$spp_cd[old_obs$spp_cd %in% c(" ATLANTIC")] = "ATPU"
old_obs$spp_cd[old_obs$spp_cd %in% c(" Balaenidae")] = "UNLW"
old_obs$spp_cd[old_obs$spp_cd %in% c(" BLACK") & old_obs$original_species_tx %in% c("BLACK SCOTER")] = "BLSC"
old_obs$spp_cd[old_obs$spp_cd %in% c(" BLACK") & old_obs$original_species_tx %in% c("BLACK GUILLEMOT")] = "BLGU"
old_obs$spp_cd[old_obs$spp_cd %in% c(" blackfish")] = "SFWH"
old_obs$spp_cd[old_obs$spp_cd %in% c(" BLK-LEGGD")] = "BLKI"
old_obs$spp_cd[old_obs$spp_cd %in% c(" BROWN")] = "BRPE"
old_obs$spp_cd[old_obs$spp_cd %in% c(" COMMON") & old_obs$original_species_tx %in% c("LOON")] = "COLO"
old_obs$spp_cd[old_obs$spp_cd %in% c(" COMMON") & old_obs$original_species_tx %in% c("EIDER")] = "COEI"
old_obs$spp_cd[old_obs$spp_cd %in% c(" CORY'S")] = "COSH"
old_obs$spp_cd[old_obs$spp_cd %in% c(" DBL CREST")] = "DCCO"
old_obs$spp_cd[old_obs$spp_cd %in% c(" FBSP)")] = "UNFR"
old_obs$spp_cd[old_obs$spp_cd %in% c(" goose-beaked whale")] = "CBWH"
old_obs$spp_cd[old_obs$spp_cd %in% c(" gray grampus")] = "RIDO"
old_obs$spp_cd[old_obs$spp_cd %in% c(" GREAT")] = "GRCO"
old_obs$spp_cd[old_obs$spp_cd %in% c(" GREAT BLK-BACK")] = "GBBG"
old_obs$spp_cd[old_obs$spp_cd %in% c(" GREATER")] = "GRSH"
old_obs$spp_cd[old_obs$spp_cd %in% c(" GUGE")] = "UNGU"
old_obs$spp_cd[old_obs$spp_cd %in% c(" HERRING")] = "HERG"
old_obs$spp_cd[old_obs$spp_cd %in% c(" HORNED")] = "HOGR"
old_obs$spp_cd[old_obs$spp_cd %in% c(" Lagenorhynchus")] = "UNDO"
old_obs$spp_cd[old_obs$spp_cd %in% c(" LESS BLK-BACK")] = "LBBG"
old_obs$spp_cd[old_obs$spp_cd %in% c(" LOC3)")] = "UNKN"
old_obs$spp_cd[old_obs$spp_cd %in% c(" MANX")] = "MASH"
old_obs$spp_cd[old_obs$spp_cd %in% c(" NK") & old_obs$original_species_tx %in% c("LOON")] = "UNLO"
old_obs$spp_cd[old_obs$spp_cd %in% c(" NK") & old_obs$original_species_tx %in% c("BIRD")] = "UNBI"
old_obs$spp_cd[old_obs$spp_cd %in% c(" NK") & old_obs$original_species_tx %in% c("CORMORANT")] = "UNCO"
old_obs$spp_cd[old_obs$spp_cd %in% c(" NK") & old_obs$original_species_tx %in% c("GREBE")] = "UNGR"
old_obs$spp_cd[old_obs$spp_cd %in% c(" NK") & old_obs$original_species_tx %in% c("GULL")] = "UNGU"
old_obs$spp_cd[old_obs$spp_cd %in% c(" NK") & old_obs$original_species_tx %in% c("MERGANSER")] = "UNME"
old_obs$spp_cd[old_obs$spp_cd %in% c(" NK") & old_obs$original_species_tx %in% c("MURRE")] = "UNMU"
old_obs$spp_cd[old_obs$spp_cd %in% c(" NK") & old_obs$original_species_tx %in% c("SHEARWATER")] = "UNSH"
old_obs$spp_cd[old_obs$spp_cd %in% c(" NK") & old_obs$original_species_tx %in% c("TERN")] = "UNTE"
old_obs$spp_cd[old_obs$spp_cd %in% c(" NK") & old_obs$original_species_tx %in% c("STORM PETREL")] = "UNSP"
old_obs$spp_cd[old_obs$spp_cd %in% c(" NORTHERN") & old_obs$original_species_tx %in% c("GANNET")] = "NOGA"
old_obs$spp_cd[old_obs$spp_cd %in% c(" NORTHERN") & old_obs$original_species_tx %in% c("FULMAR")] = "NOFU"
old_obs$spp_cd[old_obs$spp_cd %in% c(" Orca or Globicephala)")] = "UNWH"
old_obs$spp_cd[old_obs$spp_cd %in% c(" RED-THROATED")] = "RTLO"
old_obs$spp_cd[old_obs$spp_cd %in% c(" SOOTY")] = "SOSH"
old_obs$spp_cd[old_obs$spp_cd %in% c(" spotter porpoise")] = "ASDO"
old_obs$spp_cd[old_obs$spp_cd %in% c(" streaker porpoise")] = "STDO"
old_obs$spp_cd[old_obs$spp_cd %in% c(" PEBL)")] = "UNSP"
old_obs$spp_cd[old_obs$spp_cd %in% c(" TERN)")] = "UNTE"
old_obs$spp_cd[old_obs$spp_cd %in% c(" THICK-BILLED")] = "TBMU"
old_obs$spp_cd[old_obs$spp_cd %in% c(" THIN-BILLED")] = "COMU"
old_obs$spp_cd[old_obs$spp_cd %in% c(" WHITE-WINGED")] = "WWSC"
old_obs$spp_cd[old_obs$spp_cd %in% c(" WILSON")] = "WISP"
old_obs$spp_cd[old_obs$spp_cd %in% c("CRTE")] = "UCRT"
old_obs$spp_cd[old_obs$spp_cd %in% c("TEAL")] = "UNTL"
old_obs$spp_cd[old_obs$spp_cd %in% c("UNPI")] = "UNSE"
old_obs$spp_cd[old_obs$spp_cd %in% c(" BLACK") & old_obs$original_species_tx %in% c("SCOTER")] = "BLSC"
old_obs$spp_cd[old_obs$spp_cd %in% c(" BLACK") & old_obs$original_species_tx %in% c("GUILLEMOT")] = "BLGU"
old_obs$spp_cd[old_obs$spp_cd %in% c("") & old_obs$original_species_tx %in% c("LOON")] = "UNLO"
old_obs$spp_cd[old_obs$spp_cd %in% c("") & old_obs$original_species_tx %in% c("BIRD")] = "UNBI"
old_obs$spp_cd[old_obs$spp_cd %in% c("") & old_obs$original_species_tx %in% c("CORMORANT")] = "UNCO"
old_obs$spp_cd[old_obs$spp_cd %in% c("") & old_obs$original_species_tx %in% c("GREBE")] = "UNGR"
old_obs$spp_cd[old_obs$spp_cd %in% c("") & old_obs$original_species_tx %in% c("GULL")] = "UNGU"
old_obs$spp_cd[old_obs$spp_cd %in% c("") & old_obs$original_species_tx %in% c("MERGANSER")] = "UNME"
old_obs$spp_cd[old_obs$spp_cd %in% c("") & old_obs$original_species_tx %in% c("MURRE")] = "UNMU"
old_obs$spp_cd[old_obs$spp_cd %in% c("") & old_obs$original_species_tx %in% c("SHEARWATER")] = "UNSH"
old_obs$spp_cd[old_obs$spp_cd %in% c("") & old_obs$original_species_tx %in% c("TERN")] = "UNTE"
old_obs$spp_cd[old_obs$spp_cd %in% c("") & old_obs$original_species_tx %in% c("STORM PETREL")] = "UNSP"
old_obs$spp_cd[old_obs$spp_cd %in% c("GLSP")] = "PIWH"


#second go around
old_obs$spp_cd[old_obs$spp_cd %in% c('CAGO')] = 'CANG' #(canada goose)
old_obs$spp_cd[old_obs$spp_cd %in% c('HEGU')] = 'HERG' #(herring gull)
old_obs$spp_cd[old_obs$spp_cd %in% c('UMMM')] = 'UNMM' #(unidentified marine mammal)
old_obs$spp_cd[old_obs$spp_cd %in% c('TRAW')] = 'BOTD' #(boat trawler or dragger)
old_obs$spp_cd[old_obs$spp_cd %in% c('ROTE')] = 'ROST' #(roseate tern)
old_obs$spp_cd[old_obs$spp_cd %in% c('BEGSEG')] = 'BEGCNT' #but shouldn't be in the observation table
old_obs$spp_cd[old_obs$spp_cd %in% c('BASW')] = 'SHOR'  #(unidentified plover, I think I was debating addind a code for unidentified Charadriinae or Charadriidae but for now this works)

#Remaning unkown codes
old_obs$spp_cd[old_obs$spp_cd %in% c('YTVI','CASP','LUDU','RODO','RUTO','SKSP','3','12') ] = 'UNKN'

#observation2 <<- old_obs
return(old_obs)
}

