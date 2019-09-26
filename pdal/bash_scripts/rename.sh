
# *** File Renaming ***
# Rename a bunch of files in a predictable way

prefix="dsm"

for FILE in *.tif; 
do
	mv "${FILE}" "${prefix}_${FILE}"
        
	echo '      Finished renaming ${FILE} to ${prefix}_${FILE}'
done
