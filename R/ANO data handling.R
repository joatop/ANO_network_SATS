library(sf)
library(tidyr)
library(dplyr)
library(stringr)
library(tidyverse)

#### download from kartkatalogen to P-drive ####
# url <- "https://nedlasting.miljodirektoratet.no/naturovervaking/naturovervaking_eksport.gdb.zip"
download(url, dest="P:/823001_18_metodesats_analyse_23_26_roos/ANO data/naturovervaking_eksport.gdb.zip", mode="w") 
unzip ("P:/823001_18_metodesats_analyse_23_26_roos/ANO data/naturovervaking_eksport.gdb.zip", 
       exdir = "P:/823001_18_metodesats_analyse_23_26_roos/ANO data/naturovervaking_eksport.gdb2")

st_layers(dsn = "P:/823001_18_metodesats_analyse_23_26_roos/ANO data/naturovervaking_eksport.gdb2")

# SOMETHING NOT WORKING YET



#### upload data from P-drive ####
## ANO
st_layers(dsn = "P:/823001_18_metodesats_analyse_23_26_roos/ANO data/Naturovervaking_eksport.gdb")
ANO.sp <- st_read("P:/823001_18_metodesats_analyse_23_26_roos/ANO data/Naturovervaking_eksport.gdb",
                  layer="ANO_Art")
ANO.geo <- st_read("P:/823001_18_metodesats_analyse_23_26_roos/ANO data/Naturovervaking_eksport.gdb",
                   layer="ANO_SurveyPoint")


#### data handling - ANO data ####
head(ANO.sp)
head(ANO.geo)

## fix NiN information on hovedtyper
ANO.geo$hovedtype_rute <- substr(ANO.geo$kartleggingsenhet_1m2,1,3) # take the 3 first characters
ANO.geo$hovedtype_rute <- gsub("-", "", ANO.geo$hovedtype_rute) # remove hyphon
unique(as.factor(ANO.geo$hovedtype_rute))

## fix NiN-variables
colnames(ANO.geo)
colnames(ANO.geo)[42:47] <- c("groeftingsintensitet",
                              "bruksintensitet",
                              "beitetrykk",
                              "slatteintensitet",
                              "tungekjoretoy",
                              "slitasje")
head(ANO.geo)

# remove variable code in the data
ANO.geo$groeftingsintensitet <- gsub("7GR-GI_", "", ANO.geo$groeftingsintensitet) 
unique(ANO.geo$groeftingsintensitet)
ANO.geo$groeftingsintensitet <- gsub("X", "NA", ANO.geo$groeftingsintensitet)
unique(ANO.geo$groeftingsintensitet)
ANO.geo$groeftingsintensitet <- as.numeric(ANO.geo$groeftingsintensitet)
unique(ANO.geo$groeftingsintensitet)

ANO.geo$bruksintensitet <- gsub("7JB-BA_", "", ANO.geo$bruksintensitet) 
unique(ANO.geo$bruksintensitet)
ANO.geo$bruksintensitet <- gsub("X", "NA", ANO.geo$bruksintensitet)
unique(ANO.geo$bruksintensitet)
ANO.geo$bruksintensitet <- as.numeric(ANO.geo$bruksintensitet)
unique(ANO.geo$bruksintensitet)

ANO.geo$beitetrykk <- gsub("7JB-BT_", "", ANO.geo$beitetrykk) 
unique(ANO.geo$beitetrykk)
ANO.geo$beitetrykk <- gsub("X", "NA", ANO.geo$beitetrykk)
unique(ANO.geo$beitetrykk)
ANO.geo$beitetrykk <- as.numeric(ANO.geo$beitetrykk)
unique(ANO.geo$beitetrykk)

ANO.geo$slatteintensitet <- gsub("7JB-SI_", "", ANO.geo$slatteintensitet) 
unique(ANO.geo$slatteintensitet)
ANO.geo$slatteintensitet <- gsub("X", "NA", ANO.geo$slatteintensitet)
unique(ANO.geo$slatteintensitet)
ANO.geo$slatteintensitet <- as.numeric(ANO.geo$slatteintensitet)
unique(ANO.geo$slatteintensitet)

ANO.geo$tungekjoretoy <- gsub("7TK_", "", ANO.geo$tungekjoretoy) 
unique(ANO.geo$tungekjoretoy)
ANO.geo$tungekjoretoy <- gsub("X", "NA", ANO.geo$tungekjoretoy)
unique(ANO.geo$tungekjoretoy)
ANO.geo$tungekjoretoy <- as.numeric(ANO.geo$tungekjoretoy)
unique(ANO.geo$tungekjoretoy)

ANO.geo$slitasje <- gsub("7SE_", "", ANO.geo$slitasje) 
unique(ANO.geo$slitasje)
ANO.geo$slitasje <- gsub("X", "NA", ANO.geo$slitasje)
unique(ANO.geo$slitasje)
ANO.geo$slitasje <- as.numeric(ANO.geo$slitasje)
unique(ANO.geo$slitasje)

## check that every point is present only once
length(levels(as.factor(ANO.geo$ano_flate_id)))
length(levels(as.factor(ANO.geo$ano_punkt_id)))
summary(as.factor(ANO.geo$ano_punkt_id))
# there's a triple and many double presences, probably some wrong registrations of point numbers,
# but also double registrations



# fix species variable
ANO.sp$Species <- ANO.sp$art_navn
unique(as.factor(ANO.sp$Species))
#ANO.sp$Species <- sub(".*?_", "", ANO.sp$Species) # lose the Norwegian name in the front
ANO.sp[,'Species'] <- word(ANO.sp[,'Species'], 1,2) # lose subspecies
ANO.sp$Species <- str_to_title(ANO.sp$Species) # make first letter capital
#ANO.sp$Species <- gsub("_", " ", ANO.sp$Species) # replace underscore with space
ANO.sp$Species <- gsub("( .*)","\\L\\1",ANO.sp$Species,perl=TRUE) # make capital letters after hyphon to lowercase
ANO.sp$Species <- gsub("( .*)","\\L\\1",ANO.sp$Species,perl=TRUE) # make capital letters after space to lowercase
unique(as.factor(ANO.sp$Species))
ANO.sp$Species <- gsub("�\u0097", "", ANO.sp$Species) # remove �\0097
unique(as.factor(ANO.sp$Species))
# removal does not work
# \u0097 stands for the special x, so these species are all hybrids


# fix typos in species names
ANO.sp <- ANO.sp %>% 
  mutate(Species=str_replace(Species,"Linnaea borealis", "Linnea borealis"))

