
# DSM Generation from LAS Input
#   Iterate over all .las files in current folder and create a .tif Digital Surface Model for each
#   Automatically determines an origin and file size based on .las metadata 
for FILE in *.laz;
do
	# Get filename without filetype suffix
        filename_prefix=${FILE%.laz}
        echo "Beginning to process file ${filename_prefix}"

	# Find origin for new tif file
	#   The metadata being read has the following syntax:
  	#   "minx": 6222500.01,
	minx_line=$(pdal info --metadata ${FILE} | grep 'minx')
	minx=`expr match "$minx_line" '.*: \([0-9]*\)[^0-9]*'`
	miny_line=$(pdal info --metadata ${FILE} | grep 'miny')
	miny=`expr match "$miny_line" '.*: \([0-9]*\)[^0-9]*'`

	# Find the Width and Height of the output file
	maxx_line=$(pdal info --metadata ${FILE} | grep 'maxx')
	maxx=`expr match "$maxx_line" '.*: \([0-9]*\)[^0-9]*'`
	maxy_line=$(pdal info --metadata ${FILE} | grep 'maxy')
	maxy=`expr match "$maxy_line" '.*: \([0-9]*\)[^0-9]*'`

	let width=maxx-minx+1
	let height=maxy-miny+1

	echo "      Min X: ${minx};  Min Y: ${miny};  Width: ${width};  Height: ${height}"

	# Actually process the data and create an output
        pdal pipeline ~/serdp_testing/pdal/json/dsm.JSON \
                --readers.las.filename="${FILE}" \
                --writers.gdal.filename="./DSM/${filename_prefix}.tif" \
		--writers.gdal.origin_x="${minx}" \
		--writers.gdal.origin_y="${miny}" \
		--writers.gdal.width="${width}" \
		--writers.gdal.height="${height}"
        echo '      Finished a file!'
done

