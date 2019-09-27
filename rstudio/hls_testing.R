
require(raster)
require(rgdal)
require(Metrics)

sentinel_red <- raster("D:/serdp/data/pendleton/input/HLS/sentinel.tif", band=3)
sentinel_nir <- raster("D:/serdp/data/pendleton/input/HLS/sentinel.tif", band=4)

landsat_red <- raster("D:/serdp/data/pendleton/input/HLS/landsat.tif", band=3)
landsat_nir <- raster("D:/serdp/data/pendleton/input/HLS/landsat.tif", band=4)

sentinel_ndvi <- (sentinel_nir-sentinel_red) / (sentinel_nir+sentinel_red)
landsat_ndvi <- (landsat_nir-landsat_red) / (landsat_nir+landsat_red)

sentinel_ndvi[sentinel_ndvi < -1] = -1
sentinel_ndvi[sentinel_ndvi > 1] = 1
landsat_ndvi[landsat_ndvi < -1] = -1
landsat_ndvi[landsat_ndvi > 1] = 1

boundary_utm <- readOGR(dsn = "D:/serdp/data/pendleton/input/HLS/pendleton_boundary.gpkg", layer = "pendleton_boundary")
boundary_utm <- spTransform(boundary, sentinel_red@crs)

sentinel_ndvi_crop <- crop(sentinel_ndvi, boundary_utm)
landsat_ndvi_crop <- crop(landsat_ndvi, boundary_utm)

sentinel_ndvi_list <- extract(sentinel_ndvi, boundary_utm)[[1]]
landsat_ndvi_list <- extract(landsat_ndvi, boundary_utm)[[1]]

sentinel_red_list <- extract(sentinel_red, boundary_utm)[[1]]
landsat_red_list <- extract(landsat_red, boundary_utm)[[1]]
sentinel_nir_list <- extract(sentinel_nir, boundary_utm)[[1]]
landsat_nir_list <- extract(landsat_nir, boundary_utm)[[1]]

ndvi_frame <- data.frame(sentinel_ndvi_list, landsat_ndvi_list, sentinel_red_list, landsat_red_list, sentinel_nir_list, landsat_nir_list)
colnames(ndvi_frame) <- c("sentinel_ndvi","landsat_ndvi","sentinel_red","landsat_red","sentinel_nir","landsat_nir")

ndvi_model <- lm(sentinel_ndvi ~ landsat_ndvi, data <- ndvi_frame)
print(summary(ndvi_model))

print(paste("Mean Error: ",mean(ndvi_model$residuals)))
print(paste("RMSE Error: ",rmse(sentinel_ndvi_list,ndvi_model$fitted.values)))
hist(ndvi_model$residuals, freq=TRUE,
     xlim=c(-0.15,0.15), breaks=seq(-0.4,0.8,0.003), 
     col="tomato", xlab="Residuals", 
     ylab="Frequency (counts)", 
     main="Residuals for HLS Sentinel- and Landsat-Derived NDVI Imagery")

red_model <- lm(sentinel_red ~ landsat_red, data <- ndvi_frame)
print(summary(red_model))
hist(red_model$residuals, freq=TRUE,
     xlim=c(-500,500), breaks=seq(-2000,7000,10), 
     col="tomato", xlab="Residuals", 
     ylab="Frequency (counts)", 
     main="Residuals for HLS Sentinel- and Landsat-Derived Red Band")

nir_model <- lm(sentinel_nir ~ landsat_nir, data <- ndvi_frame)
print(summary(nir_model))
hist(nir_model$residuals, freq=TRUE,
     xlim=c(-500,500), breaks=seq(-2000,9000,10), 
     col="tomato", xlab="Residuals", 
     ylab="Frequency (counts)", 
     main="Residuals for HLS Sentinel- and Landsat-Derived NIR Band")