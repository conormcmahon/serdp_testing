
require(raster)

file_prefix <- "D:/serdp/data/climate_global/prism/"

# Load 30-year Averages
normals_filename <- paste(file_prefix, "Normals/PRISM_ppt_30yr_normal_4kmM2_annual_bil/PRISM_ppt_30yr_normal_4kmM2_annual_bil.bil", sep="")
normals <- raster(normals_filename)

prism_year_list <- seq(1984,2018,1)
year_list <- seq(1984,2018,1)


rain_image_list <- list()
rain_residual_list <- list()

for(year_ind in 1:length(year_list))
{
  month_ind <- 1
  rain_image_list[[year_ind]] <- list()
  rain_residual_list[[year_ind]] <- list()
  for(month in c("01","02","03","04","05","06"))
  {
    rain_year_filename <- paste(file_prefix, year_list[[year_ind]], "/PRISM_ppt_stable_4kmM3_", year_list[[year_ind]], "_all_bil/PRISM_ppt_stable_4kmM3_", year_list[[year_ind]], month, "_bil.bil", sep="")
    rain_image_list[[year_ind]][[month_ind]] <- raster(rain_year_filename)
    month_ind <- month_ind + 1
  }
  for(month in c("07","08","09","10","11","12"))
  {
    rain_year_filename <- paste(file_prefix, year_list[[year_ind]]-1, "/PRISM_ppt_stable_4kmM3_", year_list[[year_ind]]-1, "_all_bil/PRISM_ppt_stable_4kmM3_", year_list[[year_ind]]-1, month, "_bil.bil", sep="")
    rain_image_list[[year_ind]][[month_ind]] <- raster(rain_year_filename)
    month_ind <- month_ind + 1
  }

  rain_residual_list[[year_ind]] <- rain_image_list[[year_ind]][[1]]
  for(residual_month in 2:12)
  {
    rain_residual_list[[year_ind]] <- rain_residual_list[[year_ind]] + rain_image_list[[year_ind]][[residual_month]]
  }
  rain_residual_list[[year_ind]] <- rain_residual_list[[year_ind]] - normals
}

