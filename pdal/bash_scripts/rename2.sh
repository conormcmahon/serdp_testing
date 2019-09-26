
# *** File Renaming ***
# Rename a bunch of files in a predictable way

prefix="dsm"

for FILE in *.tif; 
do
        [[ ${FILE} =~ dem_(.*) ]]
	file_id=${BASH_REMATCH[1]} 
	mv "dem_${file_id}" "${prefix}_${file_id}"
        
	echo "      Finished renaming ${FILE} to ${prefix}_${FILE}"
done
