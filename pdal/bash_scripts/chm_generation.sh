
# *** CHM Batch Processing ***
# This script batch processes .tif DEM and DSM images to produce CHM images of vegetation canopy height (also a .tif output)
#   Run this script in a directory containinga ./DEM and ./DSM directories, each containing .tif files, and a ./CHM directory where the outputs will be saved.
#   This assumes that input files all have names dem_XXXX and dsm_XXXX, where XXXX is an arbitrary but unique file identifier shared by the DSM and DEM
#   Output file is saved as ./CHM/chm_XXXX.tif
#   Presently, this assumes the two rasters have the same pixel size and extent. If this is NOT the case, consider using some of the solutions here: 
#      https://gis.stackexchange.com/questions/129487/subtracting-rasters-using-gdal-calculate-command

for FILE in ./DEM/*.tif; 
do
	echo "Beginning to process file ${FILE}"
	[[ ${FILE} =~ DEM/dem_(.*) ]]
	file_id=${BASH_REMATCH[1]}
	echo "      Retrieved file ID: ${file_id}"
        gdal_calc.py -A "DSM/dsm_${file_id}" -B "DEM/dem_${file_id}" --calc="A-B" --outfile "CHM/chm_${file_id}"
	 
	echo '      Finished a file!'
done
