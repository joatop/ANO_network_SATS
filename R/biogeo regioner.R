library(sf)

biogeo <- st_read("R:/GeoSpatialData/BiogeographicalRegions/Norway_Biogeography/Original/biogeografiske_regioner_omrade.shp")%>%
  st_as_sf() %>%
  st_transform(crs = st_crs(ANO.geo))

plot(biogeo[25])

nor <- st_read("input/outlineOfNorway_EPSG25833.shp")%>%
  st_as_sf() %>%
  st_transform(crs = st_crs(ANO.geo))


biogeonor <- st_intersection(nor,biogeo)

plot(biogeonor[27])
