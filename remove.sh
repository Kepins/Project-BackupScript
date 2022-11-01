#!/bin/bash


# Check if argument is present
if [[ -z "$1" ]] ; then 
	echo "Argument with directory not provided" >&2
	exit 1
fi
# Check if argument is a valid directory
if [[ ! -d "$1" ]] ; then
	echo "Argument is not a valid directory" >&2
	exit 1
fi

# Assign path to directory
BACKUP_DIR=$1

# Date length in directory name
D_LEN=19

# Remove directory with backups before this date
REMOVE_BEFORE=$(date -d 'now - 14 minutes' +"%Y-%m-%dT%H:%M:%S")

for FROM_DIR in $(find $BACKUP_DIR -maxdepth 1 -mindepth 1 -type d); do
	# Extract date from directory name
	DATE="${FROM_DIR:${#FROM_DIR}-$D_LEN:$D_LEN}"
	# Check if directory has the date a the end of the name just in case
	if [[ -z "$(date -d "$DATE" 2> /dev/null)" ]] ; then
		echo "Directory does not have a valid date in name" >&2
		exit 1
	fi
	# Check if date in name is before REMOVE_BEFORE
	if [[ $DATE < $REMOVE_BEFORE ]] ; then
		# Remove directory with all it's contents
		rm -rf $FROM_DIR
	fi
done
