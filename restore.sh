#!/bin/bash


# Check if argument is present
if [[ -z "$1" ]] ; then 
	echo "Argument with directory not provided" >&2
	exit 1
fi
# Check if argument is a valid date
if [[ ! -d "$1" ]] ; then
	echo "Argument is not a valid directory" >&2
	exit 1
fi


# Check if argument is present
if [[ -z "$2" ]] ; then
	echo "Argument with date not provided" >&2
	exit 1
fi
# Check if argument is a valid date
if [[ -z "$(date -d "$2" 2> /dev/null)" ]] ; then
	echo "Argument is not a valid date" >&2
	exit 1
fi


# Assign path to directory
BACKUP_DIR=$1


# Date for comparing
DATE_COMP=$(date -d "$2" +"%Y%m%d%H%M%S")

# Assign formated date to DATE_STR variable
DATE_STR=$(date -d "$2" +"%Y-%m-%dT%H:%M:%S")



for FROM_DIR in $(find $BACKUP_DIR -maxdepth 1 -mindepth 1 -type d); do
	source $FROM_DIR/days.meta
	if [[ -n $(echo "${DAYS_IN_WEEK[@]}" | grep -w $DATE_STR) ]] ; then
		for DAY in "${DAYS_IN_WEEK[@]}"; do
			DAY_DATE_COMP=$(date -d "$DAY" +"%Y%m%d%H%M%S")
			DAY_DATE_STR=$(date -d "$DAY" +"%Y-%m-%dT%H:%M:%S")
			if [[ $DAY_DATE_COMP -le $DATE_COMP ]] ; then
				# sudo is necessary for --same-owner
				sudo tar --same-owner --same-permission --absolute-names --extract --listed-incremental=/dev/null --file $FROM_DIR/backup_$DAY_DATE_STR.tar.gz
			fi
		done
		exit 0
	fi
done

echo "No backup from that day exists" >&2
exit 1





