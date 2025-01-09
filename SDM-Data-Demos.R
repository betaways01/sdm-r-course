#### BASICS 2

# # Spatial data in R Tutorial #

# The goal of this tutorial is to teach basic methods for working with raster # and vector data in R. In addition to demonstrating how to manipulate # spatial data objects, the tutorial demonstrates working with vector and # raster data, some of the most common GIS operations, and reading / writing # spatial data.

# INTRODUCTION TO VECTOR DATA IN R -# Let's start by creating some point data longitude <- c(-116.7, -120.4, -116.7, -113.5, -115.5, -120.8, -119.5, -113.7, -113.7, -110.7) I latitude <- c(45.3, 42.6, 38.9, 42.1, 35.7, 38.9, 36.2, 39, 41.6, 36.9) # note order (x=longitude, y=latitude)! We often say "lat-long", which is (y,x) lonlat <- cbind(longitude, latitude) head(lonlat) class(lonlat) plot(lonlat)

#### Create SpatialPoints object #### # The lonlat object is class = matrix # We will convert it to a spatial object library(sp) pts <- sp :: SpatialPoints(lonlat) # convert to spatial object class(pts) showDefault(pts) # show aspects of the object plot(pts) # compare this to plot(lonlat) # things to note: # coordinates SERVICE CONSULTION TO VECTOR DATA BLA

```
# bbox = bounding box / spatial EXTENT
# proj4string = stores coordinate reference system or "CRS". The
# CRS = NA because we haven't defined it
# Define the coordinate reference system ###
# More details about this later.
?CRS
# Create a CRS object - this is called PROJ.4 format. We will come back to
# this in the 'advanced' tutorial.
crsRef <- CRS('+proj=longlat +datum-WGS84')
crsRef
# We can also use "EPSG" codes
# See: https://epsg.io/
crsRef <- CRS('+init=epsg:4326')
crsRef
# now we define the CRS of the 'pts' object
pts <- SpatialPoints(lonlat, proj4string=crsRef)
showDefault(pts)
pts
· ### Create SpatialPointsDataFrame object ###
# Generate random values, same number as in the 'pts' object
# We will assume these are precipitation measurements
precipValue <- runif(nrow(lonlat), min-0, max-100) # see ?runif
# make a dataframe that combines points and the new data values
df <- data.frame(ID=1:nrow(lonlat), precip=precipValue)
# combine spatial + attribute data
ptsdf <- SpatialPointsDataFrame(pts, data=df)
ptsdf
str(ptsdf)
showDefault(ptsdf)
# the 'attribute' data are in slot @data
ptsdf@data
```
# the 'spatial data' (coordinates) are in slot @coords ptsdf@coords

#### Create SpatialLines & SpatialPolygons ### # We will need the 'raster' package to do this. # Note that when you load certain libraries, it can change how things behave # in your R session. For example, loading 'raster' changes the way the pts # object is printed pts # prints object I # load raster package library (raster) pts # prints just a summary lon <- c(-116.8, -114.2, -112.9, -111.9, -114.2, -115.4, -117.7) lat <- c(41.3, 42.9, 42.4, 39.8, 37.6, 38.3, 37.6) lonlat <- cbind(lon, lat) # make spatial lines object Ins <- spLines(lonlat, crs=crsRef) lns # make spatial polygon object pols <- spPolygons(lonlat, crs=crsRef) pols str(pols) # can be complex if multiple polygons and holes # make a plot plot(pols, axes-TRUE, las-1) #las = style of axis labels plot(pols, border=' blug', col='yellow', lwd=3, add=TRUE) points(pts, col=' = ' , pch=20, cex=3) dev.off()

plot(lns)

```
# INTRODUCTION TO RASTER DATA IN R -
#### Create a RasterLayer ####
library(raster)
# see ?raster. There are MANY ways to make a raster. Here we are providing
# only the size and extent of the raster, but no data.
r <- raster(ncol=10, nrow=10, xmx=-80, xmn=-150, ymn=20, ymx=60)
r
# things to note:
# dimensions
# resolution
# extent
# crs (the raster function will default to angular coordinates and WGS84)
plot(r) # error! There's no data to plot.
# Let's add some random values
values(r) <- runif(ncell(r)) # random numbers
r
plot(r)
```

```
# Add sequence of numbers
values(r) <= 1:ncell(r)
r
plot(r) # note the order in which values were added = row-wise
#### Create a RasterStack ####
# Let's create a couple of new rasters. Here we create two new rasters using
# simple math functions
r2 <- r * r
r3 <- sqrt(r)
# 'stack' function will combine the three rasters into one object with three.
# layers
s <- stack(r, r2, r3)
# IIMPORTANT! You can only stack rasters that have the same
# resolution and extent. You will learn that this can become
# a major challenge when working with multiple raster datasets
# from different sources that differ in resolution, extent, etc.
ട്ട
```

```
plot(s)
```
#### Create a RasterBrick #### # In many ways a brick is the same as a stack. The only real differences is # how the files are saved to disk. A stack is comprised of multiple raster # files, whereas a brick is a single file with multiple layers. Once they # are read into R, they are basically identical. b <- brick(s) P plot(b)

# READING / WRITING SPATIAL DATA ### Read in a shapefile from disk ### library(raster) # Here we will load an example file provided with the raster package & so that is # why we are using the 'system.file' function. This DOES NOT work for files that # are not included as part of an R package. filename <- system.file("external/lux.shp", package="raster") filename

```
# lots of ways to read .shp,
# 'shapefile' is a good option from the raster package
?shapefile
s <- shapefile(filename)
S
# s is a SpatialPolygonsDataFrame
# it has 12 features each with 4 attributes. Make sense?
```
### Save a shapefile to disk ### # Provide Spatial* object and filename to the 'shapefile' function outfile <- 'test.shp' = shapefile(s, outfile, overwrite=TRUE)

# let's have a look at what files were written ff <- list.files(patt="^test") ff # note that four files were written # delete the file from disk file.remove(ff)

# let's have a look at what files were written ff <- list.files(patt="Atest") ff # note that five files were written # delete the file from disk file.remove(ff) ### Read in a raster from disk #### f <- system.file("external/rlogo.grd", package="raster") f # this is a .grd file. There are many raster file types. # raster function reads in a file as a RasterLayer r1 <- raster(f) r1 # note number of 'bands; class(r1) plot(r1) r2 <- raster(f, band=2) r2 plot(r2) # For multi-band rasters (a single raster file with multiple layers), # you really want it to be a 'RasterBrick' object b <= brick(f) b #RasterBrick plat(b)

#### > brick(f)

| class : RasterBrick |  |
  | --- | --- |
  | dimensions : 77, 101, 7777, 3 (nrow, ncol, ncell, nlayers) |  |
  | resolution : 1, 1 (x, y) |  |
  | extent : 0, 101, 0, 77 (xmin, xmax, ymin, ymax) |  |
  | : +proj=merc +lon_0=0 +k=1 +x_0=0 +y_0=0 +datum=NGS84 +units-m +no_defs | Cr5 |
  | source : rlogo.grd |  |
  | : red, green, blue | names |
  | min values : 0, 0, 0 |  |
  | max values : 255, 255, 255 |  |
  | > stack(f) |  |
  
  class : RasterStack dimensions : 77, 101, 777, 3 (nrow, ncol, ncell, nlayers) resolution : 1, 1 (x, y) extent : 0, 101, 0, 77 (xmin, xmax, ymin, ymax) crs min values : 0, 0, છે max values : 255, 255, 255

plotRGB(b) # plot bands to the Red, Green, Blue (RGB) plat(b[[3]]) # Use double brackets [[3]] to plot third layer / band only # stack s <- stack(f) #RasterStack s # note number of 'layers' plot(s) plotRGB(s)

#### Save a raster to disk #### # Here, we will write the file as a GeoTiff (.tif) # Provide Raster* object and filename. The file format is assumed from # the filename extension. Or you can use 'format' argument. # The 'datatype" argument can be used to set whether data are # integer, float, etc. x <- writeRaster(s, 'output.tif', overwrite=F) x # a single file with multiple bands list.files(patt="^output") file.remove('output.tif')

#### Do not use rgdal

| > # CODRDINATE REFERENCE SYSTEMS ... |
  | --- |
  | > library(rgdal) |
  | Please note that rgdal will be retired by the end of 2023, |
  | plan transition to sf/stars/terra functions using GDAL and PROJ |
  | at your earliest convenience. |
  | rgdal; version: 1.5-32, (SVN revision 1176) |
  | Geospatial Data Abstraction Library extensions to R successfully loaded |
  | Loaded GDAL runtime: GDAL 3.4.Z, released 2022/03/08 |
  | Path to GDAL shared files: /Library/Frameworks/R.framework/Versions/4.1-arm64/Resources/Library/rgdal/gdal |
  | GDAL binary built with GEOS: FALSE |
  | Laaded PROJ runtime: Rel. 8.2.1, January 1st. 2022, [PJ_VERSION: 821] |
  | Path to PROJ shared files; /Library/Frameworks/R.framework/Versions/4.1-arm64/Resources/Library/rgdal/proj |
  | PROJ CDN enabled: FALSE |
  | Linking to sp version: 1.4-7 |
  | To mute warnings of possible GDAL/OSR exportToProj4() degradation, |
  | use options("rgdal_show_exportToProj4_warnings"="none") before loading sp or rgdal. |
  | > library(raster) |
  | > |
  
  ```
#library(rgdal)
library(raster)
#### Projecting vector data ####
# lets have a look at an example
f <- system.file("external/lux.shp", package="raster")
p <- shapefile(f)
p
plot(p)
crs(p)
# What if our data do not come with a defined CRS?
pp <- p
crs(pp) <- NA
crs(pp)
# * Tf* you know the projection you can *assign* it by providing an
# appropriate text string for the CRS (more on this later).
crs(pp) <- CRS("+init-epsg:4326")
crs(pp)
# IMPORTANT! You cannot use the CRS function to CONVERT
# to a different CRS - the CRS function is used only to ASSIGN a
# known CR5.
# To CONVERT to a new CRS, you must PROJECT / TRANSFORM your data.
# A CRS is only a LABEL.
# Let's transform / project the data to a new CRS using the 'spTransform'
# Function.
# First, define the CRS
newcrs <- CRS("+proj=robin +lon_0-0 +x_0-0 +y_0-0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs")
pProj <- spTransform(p, newcrs) # this performs the projection
pProj # note change in units (extent)
# now let's plot both versions of the data
dev.off() # clear existing plot window
par(mfrow-c(1,2)) # plot two plots in same window, one row two columns
plot(pProj, axes=T, main-"Projected")
plot(p, axes=T, main="long-lat / angular")
dev.off()
# transform back to long/lat
p2 <- spTransform(pProj, CRS("+proj=longlat +datum=WG584"))
```
### Projecting raster data #### # IMPORTANT! If you want to have your vector and raster data # in the same projection, it is better to transform the VECTOR # data to the projection of the raster data than vice versa. # Let's look at why r <- raster(xmn =- 110, xmx =- 90, ymn=40, ymx=60, ncols=40, nrows=40) r <- setValues(r, 1:ncell(r)) r # assumes long/lat and WGS84 plot(r) ncell(r) # define new projection newproj <- "+proj=lcc +lat_1=48 +lat_2=33 +lon_0=-100 +ellps=WGS84" # 'projectRaster' function from raster pacakge pr1 <- projectRaster(r, crs-newproj) crs(pr1) pr1 # note the min / max values have changed ncell(pr1) # note the number of cells has changed! # WHAT HAPPENED HERE? # let's define cell size using 'res' argument pr2 <- projectRaster(r, crs-newproj, res=20000) pr2 plot(pr2)

# To have more control over the projection of rasters, you can provide an # existing raster to inform the transformation. First, we use 'projectExtent' # because we do not have an existing raster object, pr3 <- projectExtent(n, newproj) pr3

# next we use 'projectRaster' and provide both rasters to the function instead # of one raster and a CRS pr3 <- projectRaster(r, pr3) pr3 plot(pr3)

```
# To have more control over the projection of rasters, you can provide an
# existing raster to inform the transformation. First, we use 'projectExtent'
# because we do not have an existing raster object.
pr3 <- projectExtent(r, newproj)
pr3
# next we use 'projectRaster' and provide both rasters to the function instead
# of one raster and a CRS
pr3 <- projectRaster(r, pr3)
pr3
plot(pr3)
Important Notes:
  # Transforming a raster changes the values in the raster
  # because new values must be estimated for the new # of cells.
  # How might this process differ for continuous vs. categorical data?
  # See:
  ?projectRaster
I
# Also, when projecting rasters, it is best to use an "equal area projection"
# if possible to ensure grid cells are the same size.
```
### BASICS 3

```
ISBEN SEEKHIBOODLa . PT'PA MA
> names(z) <- 'Zone'
> # coerce RasterLayer to SpatialPolygonsDataFrame
> z <- as(z, 'SpatialPolygonsDataFrame')
> Z
class : SpatialPolygonsDataFrame
features : 4
extent
variables   : 1
names : Zone
min values  : 
> plot(z, col='light blue', lwd=2)
> points(spts, col='light gray', pch=20, cex=6)
> text(spts, 1:nrow(pts), col='red', font-2, cex=1.5)
> lines(p, col='blue', lwd=2)
A
Files Plots Packages Help Git Viewer Presentation
```
* Zoom - Export . 0

![](_page_11_Figure_2.jpeg)

```
#### Union ####
u <- union(aggregate(p), z)
crs(p) <- crs(z)
u
plot(u)
# Color each resulting polygon using a color selected at random
set.seed(5)
# u is comprised of numerous polygons that result from the union of p and z
plot(u, col=sample(rainbow(length(u)]))
```

```
#### Perform spatial queries ####
pts <- matrix(c(6, 6.1, 5.9, 5.7, 6.4, 50, 49.9, 49.8, 49.7, 49.5), ncol-2)
spts <- SpatialPoints(pts, proj4string-crs(p))
plot(z, col='light blue', lwd=2)
points(spts, col='light gray', pch=20, cex=6)
text(spts, 1:nrow(pts), col=' , font=2, cex=1.5)
lines(p, col='blue', lwd=2)
# perform query at points using 'over' function
over(spts, p) # why are rows #4 and #5 NA?
over (spts, z) # why is point #4 NA?
```
Other Operations working with Raster:
  
  - Unions

# Vectors and Raster in R

# This tutorial is an overview of working with vector & raster data in R, with # an emphasis on combining point vector data and climate grids. There is some # repetition, with the "basic" tutorial, but that is intended to help practice # key skills / concepts.

library(rgdal) # 'Geospatial' Data Abstraction Library ('GDAL') library(raster) # for all things raster and more library(dismo) # species distribution modeling and much more library(maps) # quick plotting of countries, etc. library(gtools) # various functions library(rasterVis) # raster visualization methods library(fields) # Curve / function fitting for spatial analyses library(tcltk) #build GUIs for R interface

setwd("/Users/mfitzpatrick/code/PRStats_SDMs") #setwd(tk_choose.dir())

# Working with vector point data -# Read shapefile swEuc <- shapefile("data/swEucalyptus.shp") class(swEuc) plot(swEuc)

# swEuc is a spatial object with two types of information # 1. attribute data (i.e., species names) # 2. spatial information (geographic coordinates and a CRS) # Have a look at the attribute table, it is in the @data slot head(swEuc@data)

# Check the spatial attributes head(swEuc@coords) swEuc@bbox extent(swEuc) #function from 'raster' package

# Let's look at the projection swEuc@proj4string projection(swEuc) #function from 'raster' package

# let's get just the attribute data swTab <- data.frame(swEuc@data)

# now all we have are attribute data, spatial information is gone head(swTab) class(swTab) str(swTab) projection(swTab) plot(swTab$x, swTab$y) # compare to plot of swEuc # Your data will NOT be a spatial object if you only have an Excel spreadsheet # You'll need to make it a spatial object

# let's turn the attribute table back into a spatial object # to do so, we need to provide the coordinates and ideally a CRS # if you have a table with coordinates and attribute data, you can use the ?sp: : coordinates # function which columns should be treated as coordinates coordinates(swTab) <- c("x", "y") class(swTab) str(swTab) projection(swTab) swTab@proj4string plot(swTab)

# Next, we need to define the spatial projection of the data

# if you know the projection, you can consult

# http://www.spatialreference.org or https://epsg.io/

# to get the projection in the

# appropriate PROJ. 4 format or EPSG code. Be careful - these resources

# can be a mess with lots of projections that you

# probably don't want to use

# In this case, we know where the data came from ... so we can just assig

# CRS label using the original spatial object.

### swTab@proj4string <- swEuc@proj4string

# project the data into a new coordinate system

# Get a new proj4string from http://www.spatialreference.org

# and give it a try

crsProj <- "+proj=longlat +ellps=GRS80 +datum=NAD83 +no_defs" ?sp : : spTransform

swTabProj <- spTransform(swTab, CRS=crsProj) plot(swTabProj)

#write new, projected version to shapefile

outfile <- "swProj.shp"

shapefile(swTabProj, outfile, overwrite=TRUE)

# Retrieving & preparing species occurrence data from GBIF ---# Global Biodiversity Information Facility (http://gbif.org) # Lets get data for karri (Eucalyptus diversicolor, one of the tallest # tree species in the world, endemic to southwestern Australia) # gbif function from 'dismo' ?gbif # many other ways to download species data: # library(sppocc) #library(rgbif) #library(rinat) #library(BIEN) #library(rbison) #library(ridigbio) #library(neotoma)

karri <- gbif("Eucalyptus", species="diversicolor", nrecs=200, geo-F) # note you can limit to a certain geographic extent, but we will skip that here class(karri) dim(karri) # 127 columns! View(karri) head(karriSdatasetName) # many records are from iNaturalist

# let's reduce the data to a few useful columns # but first, let's save the projection information that is # stored in the 'geodeticDatum column unique(karri$geodeticDatum) crsKarri <- "WGS84" # see ?subset = useful function karri <- subset(karri, select=c("species", "country", "lat", "lon", "locality", "year", "coordinateUncertaintyInMeters")) # review the attributes, duplicates, etc dim(karri)

duplicated(karri) #lots of duplicated records - common problem with GBIF data #View(karri[duplicated(karri),]) karri <- unique(karri) dim(karri)

| # lets select / highlight different points based on their attributes |
  | --- |
  | karri. year <- subset(karri, year <1900) # old records |
| karri.loc <- karri[grep("Walpole", karri$locality), ] # in 'Walpole' |
| plot(swPolyProj) |
  | plot(karri, pch=21, bg=rgb(0,0,1,0.5), add=T) |
  | # near Walpole |
  | plot(karri.loc, pch=20, col="yellow", add=T) |
  | # old record pre-1900 |
  | plot(karri.year, pch=15, col=" , cex=2, add=T) |
| # which points have high uncertainty? |
| plot(swPolyProj) |
| plot(karri, pch=21, bg=rgb(0,0,1,0.5), add=T, cex=0.5) |
| plot(karri[na.omit(karriScoordinateUncertaintyInMeters)>10000,], |
| pch=15, col=rgb(1,0,0,0,0.5), add=T) |
| # Raster data ------ |
| # Downloading raster climate data from internet |
| # The 'getData' function from the 'dismo' package will easily retrieve |
| # climate data, elevation, administrative boundaries, etc. |
| # lets retrieve global bioclimatic variables at 10' resolution |
| ?getData |
| # see also |
| # library(sdmpredictors) |
| bioclimVars <- getData(name="worldclim", #other options available |
| res = 10, # resolution |
| var = "bio") # which variable(s)? |

class(bioclimVars) # raster stack # A raster stack is collection of many raster layers with the same projection,

# spatial extent and resolution.

bioclimVars

extent (bioclimVars)

plot(bioclimVars) # takes a few seconds ... plots first 16 in stack

plot(bioclimVars[[1]])

```
plot(bioclimVars[[1]])
# Loading a single raster layer
# downloaded in .bil format, comprised of two files
filePath <- paste(getwd(), "/wc10/bio10.bil", sep="")
filePath
bio19 <- raster(paste(getwd(), "/wc10/bio19.bil", sep=""))
plot(bio19)
# you can zoom to a window by clicking two locations on the plot
zoom(bio19)
# performing calculations
bio1 <- raster(paste(getwd(), "/wc10/bio1.bil", sep=""))
bio1 <- bio1/10 # Worldclim temperature data are degrees C * 10
bio1 # look at the info
plot(bio1)
# Creating a raster stack
# Let's collect several raster files from disk
# and read them as a single raster stack:
file.remove(paste(getwd(), "/wc10/", "bio_10m_bil.zip", sep-"")}
# sort the file names using ?mixedsort
files <- list.files(path-paste(getwd(), "/wc10/", sep=""),
# sort the file names using ?mixedsort
files <- list.files(path-paste(getwd(), "/wc10/", sep-""),
                   full.names-T,
                   pattern=".bil")
# we want to stack them in order by name (1-19), so we need to sort
# the file paths
list.ras <- mixedsort(files)
list.ras
# in order to stack rasters, they MUST ALL be identical in terms
# of extent, resolution, etc.
bioclimVars <- stack(list.ras)
bioclimVars
# Raster bricks
# A rasterbrick is similar to a raster stack (i.e. multiple layers with the
# same extent and resolution), but all the data are stored in a single
# file on disk.
bioclim.brick <- brick(biaclimVars) # creates rasterbrick
# can write the brick as a single file if you want;
```
# Advanced

writeRaster(bioclim.brick, "bioclim.brick.tif", overwrite=T)

# Crop rasters # Crop raster manually by drawing region of interest plot(bio19) # click twice on the map to select the region of interest drawExt <- drawExtent() drawExt bio19.sw <- crop(bio19, drawExt) plot(bio19.sw)

# Alternatively, provide coordinates for the limits of the region of interest: coordExt <- c(110, 130, -37, -18) # Australia bio19.sw <- crop(bio19, coordExt) plot(bio19.sw)

# Or crop a raster stack using a polygon extent swPolyProj <- spTransform(swPoly, projection(bio19.sw)) polyExt <- extent(swPolyProj) bioclimVars.sw <- crop(bioclimVars, polyExt) plot(bioclimVars.sw)

13 plot(bioclimVars.sw) plot(bioclimVars.sw[[1]]) plot(swPolyProj, add=T)

# or use *mask* to crop boundary of polygon plot(mask(bio19.sw, swPolyProj)) swBioClim <- mask(bioclimVars.sw, swPolyProjD #

# Changing projection # Use 'projectRaster' function: bio19.swProj <- projectRaster(bio19.sw, crs="+proj=merc +lon_0=0 +k=1 +x_0=0 +y_0=0 +a=63 bio19.swProj # notice info at coord.ref. # RECALL: projection of raster requires recalculation of grid values, # so values will change ncell(bio19.sw) ncell(bio19.swProj) cellStats(bio19.sw, max) cellStats(bio19.swProj, max)
         
         ### cellStats(bio19.swProj, max)
         
         # Extract values from raster # generate some random locations set.seed(9032020) coords <- cbind(x=runif(100,115,130), y=runif(100,-35,-20)) head(coords) plot(bio19.sw) points(coords) # Use 'extract' function bio19Dat <- extract(bio19.sw, coords) coords <- cbind(coords, bio19Dat) # raster values head(coords) coords <- na.omit(coords) # are incorporated to the dataframe plot(bio19.sw) points(coords[,1:2])
         
         # extract bio19 values using buffer around points climBuff <- extract(bio19.sw, #raster karri, #ppoints to buffer cellnumbers=TRUE, #return cell numbers too? buffer=100000) # buffer size in meters
         
         class(climBuff) length(climBuff) head(climBuff[[1]]) # Using 'rasterToPoints' : bio19Pts <- data.frame(rasterToPoints(swBioClim$bio19)) head(bio19Pts) dim(bio19Pts) #use 'rasterize' to recreate raster from points & data newRast <- rasterize(bio19Pts[,1:2], swBioClim$bio19, field=bio19Pts$bio19) plot(newRast)
         
         # And also, the 'click' function will get values from particular locations in the map plot(swBioClimSbio19) # click n times in the map to get values click(swBioClim$bio19, n=5)
         
         # Changing raster resolution # Use `aggregate' function : bio19.swLowres <- aggregate(swBioClimSbio19, fact=4, fun-mean) bio19.swLowres swBioClimSbio19 # compare par(mfcol=c(1,2)) plot(swBioClimSbio19, main="original") plot(bio19.swLowres, main-"low resolution")
         
         # Here's a very useful trick if you have rasters that almost match, # but will not stack because they do not align perfectly library(gdalUtils) # install if you don't have it junkR <- aggregate(swBioClimSbio19, fact=2, fun=mean) stack(junkR, swBioClim) # error # have a look at: ?align_rasters
         
         ?align_rasters
         
         # Can you get them to stack?
         
         ```
         # Elevations, slope, aspect, etc
         # Download elevation data:
         dev.off()
         elevation <- getData('alt', country='AUS')
         plot(elevation)
         # I draw my extent to capture the Australian Alps, in the SE corner of AUS
         elevation.c <- crop(elevation, drawExtent())
         plot(elevation.c)
         ```
         
         ```
         # Some quick maps:
         slopAsp <- terrain(elevation.c, opt=c('slope', 'aspect' ), unit='degrees' )
         par(mfrow=c(1,2))
         plot(slopAsp)
         dev.off()
         slope <- terrain(elevation.c, opt='slope')
         aspect <- terrain(elevation.c, opt='aspect')
         hill <- hillShade(slope, aspect, 40, 270)
         plot(hill, col=grey(0:100/100), legend=FALSE, main='Australian Alps')
         plot(elevation.c, col=rainbow(25, alpha=0.35), add=TRUE)
         ```
         # Saving and exporting raster data # 'writeRaster' can export to many different file types
         
         # Saving and exporting raster data # 'writeRaster' can export to many different file types ?writeRaster writeRaster(bio19.sw, filename="bio19.sw.grd") 共和党组织和党委党委副副副副副副副副副副副副副副副书记《教学委书记《教学委书》书记《教科学校》《教学课书》《教师》《教学教学》《教学教学》《教学》《教学
         
         