#!/bin/bash

#Author: Pulkit
#Date: 06-Sept-2018

SH_NAME="functions.sh"

# CopyOrCompare function
# Accepts Parameters:
# 1. Local file with path
# 2. Git File with path
# 3. 'y' for plugin or 'n' for others
# 4. txt file which will contain the path of new Infrastructure or jobs
# 5. txt file which will contain the name for new additions of Infrastructure or jobs for commit in git
# 6. txt file which will contain the path for difference of Infrastructure or jobs
# 7. txt file which will contain the name of Infrastructure or job for commit in git
# 8. 'y' for Infrastructure backup and 'n' for other backup.
# 9. 'y' for users Infrastructure backup and 'n' for others
CopyOrCompare() {
	local varLocalFile=$1
	local varGitFile=$2
	local varPlugin=$3
	local varNewList=$4
	local varNewListName=$5
	local varDiffList=$6
	local varDiffListName=$7
	local varMachines=$8
	local varUsers=$9
	local varGitFolder=$(echo ${varGitFile%/*})
	local varFileName=$(echo ${varGitFile##*/})

	local varPB_GitFolder=$varGitFolder
	local varCheckInFile=""

	if [[ "$varUsers" == "y" ]]; then
		varFileName=$(echo ${varGitFolder##*/})/config.xml
		varJobName="$(echo ${varGitFile#*/} | cut -d'/' -f2)"
	elif [[ "$varUsers" == "n" ]]; then
	        if [[ "$varMachines" == "n" ]]; then
		        varJobName="$(echo ${varGitFile#*/} | cut -d'/' -f2)"
		elif [[ "$varMachines" == "y" ]]; then
			varJobName=$varFileName
			varCheckInFile=$(echo ${varGitFile#*/})
			varPB_GitFolder=$varCheckInFile
	        fi
	fi
		
	if [[ "$(echo $varPB_GitFolder)" == *"userContent/brahma/customizations/"* ]]; then
		varFileName=$(echo $varPB_GitFolder | cut -d'/' -f4-)
	fi
	
	if [[ ! -e PostBuildFiles ]]; then
		mkdir -v PostBuildFiles
	fi
						
	if [[ ! -f ${varGitFile} ]]; then
		
		CopyFiles "${varLocalFile}" "${varGitFile}" ${varPlugin}

		echo ${varGitFile#*/} >> ${varNewList}
		echo $varFileName >> ${varNewListName}

		if [[ "$varPB_GitFolder" == *"jobs"* ]]; then
			varPB_GitFolder="jobs"
		fi

		if [[ "$varPlugin" == "n" ]]; then
				if [[ "$(echo $varPB_GitFolder | cut -d'/' -f2)" == *".xyz"* ]]; then
					  varPB_CheckInFile=$(echo $varPB_GitFolder | cut -d'/' -f2 | cut -d'.' -f1  )
				else
					  varPB_CheckInFile=$(echo $varPB_GitFolder | cut -d'/' -f1  )
				fi

				if [[ "$varPB_CheckInFile" == "jobs" ]]; then
					   filename=jenkins_jobChange
			else
				filename=${varPB_CheckInFile}_${varJobName}
				fi
		else
			filename=jenkins_${varJobName}																		
		fi

		# Create appropriate filename for PostBuildFiles
		if [[ "$varUsers" == "y" && ! "$varPB_GitFolder" == "jobs" ]]; then
			filename=jenkins_Users
		elif [[ "$varCheckInFile" == *"scriptler/scripts"* ]]; then
			filename=jenkins_scriptler_scripts
		elif [[ "$varCheckInFile" == *"jenkins_install/"*".xml" && ! "$varJobName" == "scriptler.xml" && "$varUsers" == "n" && ! "$varJobName" == "config.xml" && ! "$varJobName" == "credentials.xml" && ! "$varJobName" == "JUNIT_happypath.xml"  ]]; then
			filename=jenkins_xmlinstall_configs
		elif [[ "$varCheckInFile" == *"jenkins_install/"*".xml" && "$varJobName" == "config.xml" && "$varUsers" == "n" ]]; then
		        filename=jenkins_xmlinstall_config
		elif [[ "$varCheckInFile" == *"jenkins_install/"*".xml" && "$varJobName" == "credentials.xml" && "$varUsers" == "n"  ]]; then
			filename=jenkins_xmlinstall_credentials
		elif [[ "$varCheckInFile" == *"userContent/Common.sh" ]] || [[ "$varCheckInFile" == *"userContent/restartLinux.sh" ]]; then
			filename=jenkins_userContentScripts
		elif [[ "$varCheckInFile" == *"userContent/brahma/customizations/"* ]]; then
			filename=jenkins_BrahmaCustomizations
		elif [[ "$varCheckInFile" == *"userContent/shflags"* ]]; then
			filename=jenkins_userContentShflags
		elif [[ "$varCheckInFile" == *"userContent/cas_utils/"* ]]; then
			filename=jenkins_userContentCas_Utils
		fi
		
		# Add .txt extension for PostBuildFiles
		if [[ ! "$filename" == *".txt" ]]; then
			filename=$filename.txt
		fi
		
		if [[ ! -e PostBuildFiles/$filename ]]; then
			echo -n Not Changed > PostBuildFiles/$filename
		fi

		if [[ -e PostBuildFiles/$filename ]]; then
			FileInfo=$(cat PostBuildFiles/$filename)

			if [[ "$FileInfo" == "Not Changed" ]]; then
				echo -n Changed > PostBuildFiles/$filename
			fi
		else
			echo -n Changed > PostBuildFiles/$filename
		fi
	else
		CompareFiles "${varGitFile}" "${varLocalFile}" $varDiffList $varDiffListName $varMachines $varUsers $varPlugin
	fi

	# Updating $varNewListName with appropriate format to display message during commit in git
	if [[ -s $varNewListName ]]; then
		if [[ $(wc -l "$varNewListName" | awk '{print $1}') > 1 ]]; then
			echo $(sed -e :a -e 'N;s/\n/,/;ba' $varNewListName) > $varNewListName
		else
			echo $(sed -n '1p' $varNewListName) > $varNewListName
		fi
	fi

	# Updating $varDiffListName with appropriate format to display message during commit in git
	if [[ -s $varDiffListName ]]; then
		if [[ $(wc -l "$varDiffListName" | awk '{print $1}') > 1 ]]; then
			echo $(sed -e :a -e 'N;s/\n/,/;ba' $varDiffListName) > $varDiffListName
		else
			echo $(sed -n '1p' $varDiffListName) > $varDiffListName
		fi
	fi
}

# Compare funtion to compare 2 config files.
# Accepts parameter:
# 1. Git File
# 2. Local File
# 3. Difference Config List file name
# 4. Difference Job List file name
# 5. 'y' for machines Infrastructure backup and 'n' for jobs/config backup
CompareFiles() {
    local varGitSourceFile=$1
    local varLocalSourceFile=$2
    local varCheckInFile=$(echo $varGitSourceFile | cut -d'/' -f2-4 )
    local DIFF_CONFIG_LIST=$3
    local DIFF_JOB_NAME=$4
    local varMachines=$5
    local varUsers=$6
    local varPlugin=$7
    local varJobName=""
				
    #do compare and copy config.xml if difference found
    if [[ "$varUsers" == "n" ]]; then
        if [[ "$varMachines" == "n" ]]; then
			varJobName="$(echo $varCheckInFile | cut -d'/' -f2)"
			varPB_JobName=$varJobName
        elif [[ "$varMachines" == "y" ]]; then
    	    varJobName=$(echo ${varGitSourceFile##*/})
			varCheckInFile=$(echo ${varGitSourceFile#*/})
			varPB_JobName=$varJobName
        fi
    elif [[ "$varUsers" == "y" ]]; then
        local varLocal=$(echo ${varGitSourceFile%/*})
        varJobName=$(echo ${varLocal##*/})/config.xml
		varPB_JobName=$(echo ${varLocal##*/})
        varCheckInFile=$(echo ${varGitSourceFile#*/})
    fi
	
	if [[ "$(echo $varPB_GitFolder)" == *"userContent/brahma/customizations/"* ]]; then
		varJobName=$(echo $varPB_GitFolder | cut -d'/' -f4-)
	fi

	diff "$varGitSourceFile" "$varLocalSourceFile"
    if [[ $? -eq 0 ]]; then
		echo [${SH_NAME}][${LINENO}][INFO]"${varJobName} is same."

		if [[ "$varPlugin" == "n" ]]; then
	        if [[ "$(echo $varCheckInFile | cut -d'/' -f2)" == *".xyz"* ]]; then
	              varPB_CheckInFile=$(echo $varCheckInFile | cut -d'/' -f2 | cut -d'.' -f1  )
	        else
	              varPB_CheckInFile=$(echo $varCheckInFile | cut -d'/' -f1  )
	        fi

	        if [[ "$varPB_CheckInFile" == "jobs" ]]; then
	            filename=jenkins_jobChange
			else
				filename=${varPB_CheckInFile}_${varPB_JobName}
	        fi
		else
			filename=jenkins_${varJobName}																		
		fi
	
		# Create appropriate filename for PostBuildFiles
		if [[ "$varUsers" == "y" && ! "$varPB_CheckInFile" == "jobs" ]]; then
			filename=jenkins_Users
		elif [[ "$varCheckInFile" == *"scriptler/scripts"* ]]; then
			filename=jenkins_scriptler_scripts
		elif [[ "$varCheckInFile" == *"jenkins_install/"*".xml" && ! "$varJobName" == "scriptler.xml" && "$varUsers" == "n" && ! "$varJobName" == "config.xml" && ! "$varJobName" == "credentials.xml" && ! "$varJobName" == "JUNIT_happypath.xml" ]]; then
			filename=jenkins_xmlinstall_configs
		elif [[ "$varCheckInFile" == *"jenkins_install/"*".xml" && "$varJobName" == "config.xml" && "$varUsers" == "n" ]]; then
		        filename=jenkins_xmlinstall_config
		elif [[ "$varCheckInFile" == *"jenkins_install/"*".xml" && "$varJobName" == "credentials.xml" && "$varUsers" == "n"  ]]; then
			filename=jenkins_xmlinstall_credentials
		elif [[ "$varCheckInFile" == *"userContent/Common.sh" ]] || [[ "$varCheckInFile" == *"userContent/restartLinux.sh" ]]; then
			filename=jenkins_userContentScripts
		elif [[ "$varCheckInFile" == *"userContent/brahma/customizations/"* ]]; then
			filename=jenkins_BrahmaCustomizations
		elif [[ "$varCheckInFile" == *"userContent/shflags"* ]]; then
			filename=jenkins_userContentShflags
		elif [[ "$varCheckInFile" == *"userContent/cas_utils/"* ]]; then
			filename=jenkins_userContentCas_Utils
		fi
		
		# Add .txt extension for PostBuildFiles
		if [[ ! "$filename" == *".txt" ]]; then
			filename=$filename.txt
		fi
		
		if [[ ! -e PostBuildFiles/$filename ]]; then
			echo -n Not Changed > PostBuildFiles/$filename
		fi

		if [[ -e PostBuildFiles/$filename ]]; then
			FileInfo=$(cat PostBuildFiles/$filename)

			if [[ "$FileInfo" == "Not Changed" ]]; then
				echo -n Not Changed > PostBuildFiles/$filename
			fi
		else
			echo -n Not Changed > PostBuildfiles/$filename
		fi
    elif [[ $? -eq 1 ]]; then
       echo [${SH_NAME}][${LINENO}][INFO]"${varJobName} is different."
       echo $varCheckInFile >> ${DIFF_CONFIG_LIST}
       
	   # Copy files from Local to git directory
       CopyFiles "$varLocalSourceFile" "$varGitSourceFile" $varPlugin
       
	   # Add Job Name in DiffJobName.txt"
       echo ${varJobName} >> ${DIFF_JOB_NAME}

		if [[ "$varPlugin" == "n" ]]; then
			if [[ "$(echo $varCheckInFile | cut -d'/' -f2)" == *".xyz"* ]]; then
				varPB_CheckInFile=$(echo $varCheckInFile | cut -d'/' -f2 | cut -d'.' -f1  )
			else
		        varPB_CheckInFile=$(echo $varCheckInFile | cut -d'/' -f1  )
			fi

			if [[ "$varPB_CheckInFile" == "jobs" ]]; then
				filename="jenkins_jobChange"
			else
				filename=${varPB_CheckInFile}_${varPB_JobName}
			fi
		else
			filename=jenkins_${varJobName}
		fi

		# Create appropriate filename for PostBuildFiles
		if [[ "$varUsers" == "y" && ! "$varPB_CheckInFile" == "jobs" ]]; then
			filename=jenkins_Users
		elif [[ "$varCheckInFile" == *"scriptler/scripts"* ]]; then
			filename=jenkins_scriptler_scripts
		elif [[ "$varCheckInFile" == *"jenkins_install/"*".xml" && ! "$varJobName" == "scriptler.xml" && "$varUsers" == "n" && ! "$varJobName" == "config.xml" && ! "$varJobName" == "credentials.xml" && ! "$varJobName" == "JUNIT_happypath.xml" ]]; then
			filename=jenkins_xmlinstall_configs
		elif [[ "$varCheckInFile" == *"jenkins_install/"*".xml" && "$varJobName" == "config.xml" && "$varUsers" == "n" ]]; then
			filename=jenkins_xmlinstall_config
		elif [[ "$varCheckInFile" == *"jenkins_install/"*".xml" && "$varJobName" == "credentials.xml" && "$varUsers" == "n"  ]]; then
			filename=jenkins_xmlinstall_credentials
		elif [[ "$varCheckInFile" == *"userContent/Common.sh" ]] || [[ "$varCheckInFile" == *"userContent/restartLinux.sh" ]]; then
			filename=jenkins_userContentScripts
		elif [[ "$varCheckInFile" == *"userContent/brahma/customizations/"* ]]; then
			filename=jenkins_BrahmaCustomizations
		elif [[ "$varCheckInFile" == *"userContent/shflags"* ]]; then
			filename=jenkins_userContentShflags
		elif [[ "$varCheckInFile" == *"userContent/cas_utils/"* ]]; then
			filename=jenkins_userContentCas_Utils
		fi
		
		# Add .txt extension for PostBuildFiles
		if [[ ! "$filename" == *".txt" ]]; then
			filename=$filename.txt
		fi
		
		if [[ ! -e PostBuildFiles/$filename ]]; then
			echo -n Not Changed > PostBuildFiles/$filename
		fi

		if [[ -e PostBuildFiles/$filename ]]; then
			FileInfo=$(cat PostBuildFiles/$filename)
			if [[ "$FileInfo" == "Not Changed" ]]; then
				echo -n Changed > PostBuildFiles/$filename
			fi
		else
			echo -n Changed > PostBuildFiles/$filename
		fi

    elif [[ $? -eq 2 ]]; then
       echo [${SH_NAME}][${LINENO}][ERR]"Failed to compare 2 files for ${varJobName}"
       exit $?
    fi
}

# Copy files function
# Accepts parameter:
# 1. Local File name
# 2. Git File name
# 3. 'y' for plugin or 'n' for jobs 
CopyFiles() {
    local varLocalFile=$1
    local varGitFile=$2
    local varPlugin=$3
    local varGitFolder=$(echo ${varGitFile%/*})

    if [[ "$varPlugin" == "n" ]]; then
		if [[ ! -e $varGitFolder ]]; then
			echo [${SH_NAME}][${LINENO}][INFO]"Executing mkdir -pv $varGitFolder"
			mkdir -pv $varGitFolder
		fi
    else
		echo [${SH_NAME}][${LINENO}][INFO]Updating plugins.list
    fi
	
    echo [$SH_NAME][$LINENO][INFO]Executing cp -rv "$varLocalFile" "$varGitFile"
    cp -rv "$varLocalFile" "$varGitFile"
}

# Run git add command for all files or folders to add
# Accepts parameter:
# 1. File name
# 2. Git directory
AddFileOrFolderInGit() {
    local varFilesName=$1
    local DIR_GIT=$2

    pushd ${DIR_GIT}
    	git add --no-all .
    popd
}

# Perform commit message to git repo
# Accepts parameter:
# 1. Message to commit
# 2. Git directory
CommitMessageInGit() {
    local varMessage=$1
    local DIR_GIT=$2

    DATE=$(date +%d"-"%m"-"%Y"T")
    TIME=$(date +%T | grep ":" | sed 's/:/./g')
    COMMIT_DATE=${DATE}${TIME}

    pushd ${DIR_GIT}
	git commit -m "$varMessage"
    popd
    echo COMMIT_DATE=${COMMIT_DATE} > Environ.props
}
