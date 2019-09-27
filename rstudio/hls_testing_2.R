
ndvi_l <- raster("D:/serdp/data/vandenberg/Satellite_Imagery/Calculated/NDVI_OLI.tif")
ndvi_s <- raster("D:/serdp/data/vandenberg/Satellite_Imagery/Calculated/NDVI_S2_30m.tif")

boundary <- readOGR(dsn = "D:/serdp/data/vandenberg/Satellite_Imagery/Calculated/extent.gpkg", layer = "extent")
boundary <- spTransform(boundary, ndvi_s@crs)

ndvi_l_c <- crop(ndvi_l, boundary)
ndvi_s_c <- crop(ndvi_s, boundary)

ndvi_l_c[ndvi_l_c < -1] <- -1
ndvi_l_c[ndvi_l_c > 1] <- 1
ndvi_s_c[ndvi_s_c < -1] <- -1
ndvi_s_c[ndvi_s_c > 1] <- 1

data <- data.frame(getValues(ndvi_l_c), getValues(ndvi_s_c))
colnames(data) <- c("landsat", "sentinel")

model <- lm(landsat ~ sentinel, data=data)
print(summary(model))

