#!/bin/bash

#Author: Pulkit
#Date: 06-Sept-2018
#Description: Backup plugins and jobs/config.xml

SH_NAME=$(basename "${BASH_SOURCE}")

source backupJenkins/scripts/functions.sh

# Populate Job List
ls $JENKINS_HOME/jobs > ${JOB_INPUT_FILE}

# Populate plugins list
ls $JENKINS_HOME/plugins/*.jpi | sed 's:.*/::' > ${PLUGIN_LIST}

# Check plugins.list present in git. If present, then compare else add
CopyOrCompare ${WORKSPACE}/${PLUGIN_LIST} ${DIR_GIT}/plugins/${PLUGIN_LIST} "y" $NEW_LIST $NEW_NAME $DIFF_LIST $DIFF_NAME "n" "n"

if [[ -e $DIFF_LIST ]]; then
	echo "plugins.list" > $ModifiedjobName
fi

if [[ -e ${PLUGIN_LIST} ]]; then
	rm ${PLUGIN_LIST}
fi

# jobs/Config.xml
while IFS= read -r var
do
	JOB_NAME=$var
    if [[ -e $JENKINS_HOME/jobs/${JOB_NAME}/config.xml ]]; then
    
    	CopyOrCompare $JENKINS_HOME/jobs/${JOB_NAME}/config.xml ${DIR_GIT}/jobs/${JOB_NAME}/config.xml "n" $NEW_LIST $NEW_NAME $DIFF_LIST $DIFF_NAME "n" "y"
	fi
    
done < "${JOB_INPUT_FILE}"