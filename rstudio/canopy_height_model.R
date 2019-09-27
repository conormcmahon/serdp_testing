
# Includes
library(raster)

# Load LiDAR Height Data
chm <- raster("D:/serdp/data/huachuca/output/clipped_resampled/chm_filter_crop_resample.tif", band=1)
dem <- raster("D:/serdp/data/huachuca/output/clipped_resampled/dem_crop_resample.tif", band=1)
# Load LiDAR Intensity Data
int_min <- raster("D:/serdp/data/huachuca/output/clipped_resampled/int_crop_resample.tif", band=1)
int_max <- raster("D:/serdp/data/huachuca/output/clipped_resampled/int_crop_resample.tif", band=2)
int_mean <- raster("D:/serdp/data/huachuca/output/clipped_resampled/int_crop_resample.tif", band=3)
# Load Orthoimagery Rasters
ortho_red <- raster("D:/serdp/data/huachuca/output/clipped_resampled/ortho_crop_resample.tif", band=1)
ortho_green <- raster("D:/serdp/data/huachuca/output/clipped_resampled/ortho_crop_resample.tif", band=2)
ortho_blue <- raster("D:/serdp/data/huachuca/output/clipped_resampled/ortho_crop_resample.tif", band=3)
# Load NAIP NIR
naip_nir <- raster("D:/serdp/data/huachuca/output/clipped_resampled/naip_crop_resample.tif", band=4)
naip_red <- raster("D:/serdp/data/huachuca/output/clipped_resampled/naip_crop_resample.tif", band=1)
# Load Flow Accumulation Raster
flow_accum <- raster("D:/serdp/data/huachuca/output/flow_accumulation/flow_accumulation_cropped_resampled.tif", band=1)

print("Loaded Input Data")

ndvi_naip <- (naip_nir-naip_red)/(naip_nir+naip_red)
ortho_red_proj <- projectRaster(ortho_red, crs=crs(int_max))
# Terrible Sin here!
origin(ortho_red_proj) <- origin(int_max)
# Make pseudo-NDVI vegetation index measures:
int_max_rescale <- 255 - (int_max / 40) * 255
int_max_rescale[int_max_rescale > 255] = 255
int_max_rescale[int_max_rescale < 0] = 0

ndvi_pseudo <- (int_max_rescale-ortho_red_proj)/(int_max_rescale+ortho_red_proj)
vari_ortho <- (ortho_green-ortho_red)/(ortho_green+ortho_red-ortho_blue)

print("Calculated NDVI values")

height.data <- data.frame(getValues(dem), getValues(chm), getValues(int_min), getValues(int_max), getValues(int_mean), getValues(ortho_red), getValues(ortho_green), getValues(ortho_blue), getValues(naip_nir), getValues(ndvi_naip), getValues(ndvi_pseudo), getValues(flow_accum))
names(height.data) <- c("dem","chm","int_min","int_max","int_mean","ortho_red","ortho_green","ortho_blue","naip_nir","ndvi_naip","ndvi_pseudo","flow_accum")

print("Created Data Frame!")

model <- lm(chm ~ dem + int_min + int_max, data=height.data)
print(summary(model))

print("   -------------------   ")
model_ndvi <- lm(ndvi_naip ~ ndvi_pseudo, data=height.data)
print(summary(model_ndvi))

print("   -------------------   ")
model_chm_ndvi <- lm(chm ~ ndvi_naip + dem + naip_nir, data=height.data)
print(summary(model_chm_ndvi))

print("   -------------------   ")
model_flow_accum <- lm(chm ~ flow_accum, data=height.data)
print(summary(model_flow_accum))


threshold <- 5
chm_thresh <- chm
chm_thresh[chm_thresh < threshold] <- 0
chm_thresh[chm_thresh > threshold] <- threshold

library(viridis)
plot(chm, breaks=c(0,5,10,15,30), col=viridis(5))

lin <- function(x){12.5}
ttops <- vwf(CHM = chm, winFun = lin, minHeight = 16)
plot(ttops, col = "red", pch = 20, cex = 0.5, add = TRUE)

crownsPoly <- mcws(treetops = ttops, CHM = chm, format = "polygons", minHeight = 10, verbose = FALSE)
crownsPoly[["crownDiameter"]] <- sqrt(crownsPoly[["crownArea"]]/ pi) * 2
plot(crownsPoly, border = "blue", lwd = 0.5, add = TRUE)

hist(crownsPoly$crownArea, breaks=seq(0,5000,150), xlim=c(0,3000), main="ITC Output Areas", xlab="Approximate Diameter (m^2)")
hist(crownsPoly$crownDiameter, breaks=seq(0,5000,4), xlim=c(0,70), main="ITC Output Diameters", xlab="Approximate Diameter (m)")
hist(crownsSubset$height, breaks=seq(0,100,2.5), xlim=c(0,40), main="ITC Output Heights", xlab="Height")