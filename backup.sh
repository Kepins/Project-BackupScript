#!/bin/bash


# Set current date
DATE=$(date +"%Y-%m-%dT%H:%M:%S")



# Read arguments
while getopts "d:t:" OPTION; do
 : "$OPTION" : "$OPTARG" 
 case ${OPTION} in
	d ) ALL_BACKUPS_DIR=$OPTARG ;;
	t ) DIR_TO_BACKUP=$OPTARG		;;
		
esac
done

# Check if directory to backup exists
if [[ ! -d $DIR_TO_BACKUP ]]; then 
	echo "Directory to backup does not exist!">&2
	exit 1
fi

# Check if direcotry to store backups exists
if [[ ! -d $ALL_BACKUPS_DIR ]]; then
	echo "Directory to store backups does not exist!">&2
	exit 1
fi

# Set metafile name - META
META=m.meta

if [[ -f $ALL_BACKUPS_DIR/$META ]]; then
	# Load: 
	# -snapshot file - SNGZ
	# -directory for curr week - WEEK_DIR
	# -number of incremental backups done - INC_DONE
	source $ALL_BACKUPS_DIR/$META
	
	if [[ $INC_DONE -ge 6 ]] ; then	
		# Do a full backup
		FULL_BACKUP=1
		# Set directory to store backups since today
		WEEK_DIR=$ALL_BACKUPS_DIR/FROM_$DATE
	else
		# Do an incremental backup
		FULL_BACKUP=0
	fi
	
else
	# Do a first backup
	FIRST_BACKUP=1
fi


if [[ $FIRST_BACKUP -eq 1 ]]; then
	# Create metafile
	touch $ALL_BACKUPS_DIR/$META

	# Set directory to store backups since today
	WEEK_DIR=$ALL_BACKUPS_DIR/FROM_$DATE
	# Do a full backup
	FULL_BACKUP=1
fi


if [[ $FULL_BACKUP -eq 1 ]] ; then
	# Do a full backup
	echo "Doing full backup"
	
	# Create directory to store backups since today
	mkdir $WEEK_DIR
	# Set snapshot file name - SNGZ
	SNGZ=SNGZ_$DATE.sngz
	# Set backup file name - BACKUP
	BACKUP=backup_$DATE.tar.gz
	# Run tar to create SNGZ file and tar.gz
	tar --same-owner --absolute-names --create --gzip --listed-incremental=$WEEK_DIR/$SNGZ --file=$WEEK_DIR/$BACKUP $DIR_TO_BACKUP
	
	# Set number of currently done incremental backups to 0
	INC_DONE=0
	
	# Add day to the list of days that WEEK_DIR backs up
	DAYS_IN_WEEK=($DATE)
	
else
	# Do an incremental backup
	echo "Doing an incremental backup"
	
	# Set backup file name - BACKUP
	BACKUP=backup_$DATE.tar.gz
	
	# -list of days that are backed up in WEEK_DIR - DAYS_IN_WEEK
	source $WEEK_DIR/days.meta
	
	# Run tar using SNGZ file to create tar.gz
	tar --same-owner --absolute-names --create --gzip --listed-incremental=$WEEK_DIR/$SNGZ --file=$WEEK_DIR/$BACKUP $DIR_TO_BACKUP
	
	# Increment the number of currently done incremental backups
	INC_DONE=$(( $INC_DONE+1 ))
	
	# Add day to the list of days that WEEK_DIR backs up
	DAYS_IN_WEEK=("${DAYS_IN_WEEK[@]}" $DATE)
	
fi


# Update metafile
echo SNGZ=$SNGZ > $ALL_BACKUPS_DIR/$META
echo WEEK_DIR=$WEEK_DIR >> $ALL_BACKUPS_DIR/$META
echo INC_DONE=$INC_DONE >> $ALL_BACKUPS_DIR/$META

# Update $WEEK_DIR/days.meta
echo DAYS_IN_WEEK="(${DAYS_IN_WEEK[@]})" > $WEEK_DIR/days.meta

