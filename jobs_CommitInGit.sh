#!/bin/bash

#Author: Pulkit
#Date: 06-Sept-2018
#Description: Backup new created jobs only

set -e

source backupJenkins/scripts/functions.sh

SH_NAME="jobs_CommitInGit.sh"

New_list="New_list_jobs.txt"
Update_list="Update_list_jobs.txt"

# If difference list present, add files and update git 
if [[ -s ${DIFF_LIST} ]]; then
	while IFS= read -r var
	do
		GitPath=$var
		AddFileOrFolderInGit $GitPath $DIR_GIT
	done < "${DIFF_LIST}"
	
	#Create $DIFF_NAME with list of modified jobs
    echo $( cat $DIFF_NAME ) > $Update_list
fi
	
# If New list present, add folder and update git
if [[ -s ${NEW_LIST} ]]; then
	while IFS= read -r var
	do
		GitPath=$var
		AddFileOrFolderInGit $GitPath $DIR_GIT
	done < "${NEW_LIST}"

	#Create $NEW_NAME with list of newly created jobs
    echo $( cat $NEW_NAME ) > $New_list
fi

if [[ -s ${DIFF_LIST} ]]; then
	if [[ -s $ModifiedjobName ]]; then
    	if [[ $(wc -w $ModifiedjobName ) > 1 ]]; then
			echo "$(cat $ModifiedjobName), jobs" > $ModifiedjobName
        fi
    else
    	echo "jobs" > $ModifiedjobName
    fi
fi

if [[ -s ${NEW_LIST} ]]; then
	if [[ -s $NewjobName ]]; then
    	if [[ $(wc -w $NewjobName ) > 1 ]]; then
			echo "$(cat $NewjobName), jobs" > $NewjobName
        fi
    else
    	echo "jobs" > $NewjobName
    fi
fi


# Delete $NEW_LIST $NEW_NAME $DIFF_LIST $DIFF_NAME
if [[ -e $NEW_LIST ]]; then
	rm $NEW_LIST
fi

if [[ -e $NEW_NAME ]]; then
	rm $NEW_NAME
fi

if [[ -e $DIFF_LIST ]]; then
	rm $DIFF_LIST
fi

if [[ -e $DIFF_NAME ]]; then
	rm $DIFF_NAME
fi

if [[ -e $JOB_INPUT_FILE ]]; then
	rm $JOB_INPUT_FILE
fi