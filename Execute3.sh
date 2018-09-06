#!/bin/bash

#Author: Pulkit
#Date: 06-Sept-2018
#Description: This script will create necessary folders and copy files to appropriate folders in $WORKSPACE/[server_name]

set -e

# Create Users list from /users which will be required
ls /users > ${WORKSPACE}/userslist.txt

# Create jenkins_install_xml list from /jenkins_install which will be required
ls /*.xml > ${WORKSPACE}/jenkins_install_xmllist.txt

#Create jenkins_install_scriptler_scripts from /scriptler/scripts which will be required
ls /scriptler/scripts > ${WORKSPACE}/jenkins_install_scriptler_scripts.txt

#Create list of all scripts in [DIR_name]
ls $JENKINS_HOME/[DIR_name]/*.sh > "[DIR_name]Scripts.txt"

#Crate list of files for cas_utils folder
ls $JENKINS_HOME/[DIR_name]/cas_utils > "[DIR_name]Cas_Utils.txt"

#Create list of all files
find $JENKINS_HOME/[DIR_name]/[DIR_name]/customizations -type f > "[DIR_name]Customizations.txt"
find $JENKINS_HOME/[DIR_name]/makeself -type f > "[DIR_name]makeself.txt"
find $JENKINS_HOME/[DIR_name]/shflags -type f > "[DIR_name]shflags.txt"

# Create [server_name] folder in ${WORKSPACE} if not exist.
if [[ ! -e /${WORKSPACE}/[server_name] ]]; then
	mkdir -p /${WORKSPACE}/[server_name]
fi

if [[ ! -e /${WORKSPACE}/[server_name]/etc/sysconfig/network-scripts ]]; then
	mkdir -p /${WORKSPACE}/[server_name]/etc/sysconfig/network-scripts
fi

if [[ ! -e /${WORKSPACE}/[server_name]/etc/yum.repos.d ]]; then
	mkdir -p /${WORKSPACE}/[server_name]/etc/yum.repos.d
fi

if [[ ! -e /${WORKSPACE}/[server_name]/scriptler ]]; then
	mkdir -p /${WORKSPACE}/[server_name]/scriptler
fi

if [[ ! -e /${WORKSPACE}/[server_name]/scriptler/scripts ]]; then
	mkdir -p /${WORKSPACE}/[server_name]/scriptler/scripts
fi

if [[ ! -e /${WORKSPACE}/[server_name]/JenkinsAdminShare/Automation/jenkins/config ]]; then
	mkdir -p /${WORKSPACE}/[server_name]/JenkinsAdminShare/Automation/jenkins/config
fi

if [[ ! -e /${WORKSPACE}/[server_name]/JenkinsAdminShare/Automation/jenkins/slave-jenkins ]]; then
	mkdir -p /${WORKSPACE}/[server_name]/JenkinsAdminShare/Automation/jenkins/slave-jenkins
fi

if [[ ! -e /${WORKSPACE}/[server_name]/usr/lib/jenkins ]]; then
	mkdir -p /${WORKSPACE}/[server_name]/usr/lib/jenkins
fi

if [[ ! -e /${WORKSPACE}/[server_name]/[DIR_name]/[DIR_name]/customizations ]]; then
	mkdir -p /${WORKSPACE}/[server_name]/[DIR_name]/[DIR_name]/customizations
fi

if [[ ! -e /${WORKSPACE}/[server_name]/[DIR_name]/cas_utils ]]; then
	mkdir -p /${WORKSPACE}/[server_name]/[DIR_name]/cas_utils
fi

temp=$(cat [DIR_name]makeself.txt)
temp=${temp%/*}
if [[ ! -e /${WORKSPACE}/[server_name]${temp} ]]; then
	mkdir -p /${WORKSPACE}/[server_name]${temp}
fi

temp=$(cat [DIR_name]shflags.txt)
temp=${temp%/*}
if [[ ! -e /${WORKSPACE}/[server_name]${temp} ]]; then
	mkdir -p /${WORKSPACE}/[server_name]${temp}
fi


# Copy fstab
cp -v /etc/fstab ${WORKSPACE}/[server_name]/etc/fstab

# Copy user list file
cp -v /etc/passwd ${WORKSPACE}/[server_name]/etc/passwd

# Copy ifcfg-eth0
cp -v /etc/sysconfig/network-scripts/ifcfg-eth0 ${WORKSPACE}/[server_name]/etc/sysconfig/network-scripts/ifcfg-eth0

# Copy jenkins.repo.rpmsave
cp -v /etc/yum.repos.d/jenkins.repo.rpmsave ${WORKSPACE}/[server_name]/etc/yum.repos.d/jenkins.repo.rpmsave

# Copy jenkins
echo ${JENKINS_PWD} | sudo -S cat /etc/sysconfig/jenkins > ${WORKSPACE}/[server_name]/etc/sysconfig/jenkins

# Copy scriptler.xml
cp -v /scriptler/scriptler.xml ${WORKSPACE}/[server_name]/scriptler/scriptler.xml

# Copy config.xml
cp -v /config.xml ${WORKSPACE}/[server_name]/config.xml

# Copy credentials.xml
cp -v /credentials.xml ${WORKSPACE}/[server_name]/credentials.xml

# Copy JenkinsAgent.txt
cp -v /JenkinsAdminShare/Automation/jenkins/config/JenkinsAgent.txt ${WORKSPACE}/[server_name]/JenkinsAdminShare/Automation/jenkins/config/JenkinsAgent.txt

# Copy NodeList.txt
cp -v /JenkinsAdminShare/Automation/jenkins/config/NodeList.txt ${WORKSPACE}/[server_name]/JenkinsAdminShare/Automation/jenkins/config/NodeList.txt

# Copy resolv.conf 
cp -v /etc/resolv.conf ${WORKSPACE}/[server_name]/etc/resolv.conf

# Copy help_GA.png
if [[ -e $JENKINS_HOME/[DIR_name]/help_GA.png ]]; then
	cp -v $JENKINS_HOME/[DIR_name]/help_GA.png ${WORKSPACE}/[server_name]/[DIR_name]/help_GA.png
fi

# Copy JUNIT_happypath.xml
if [[ -e $JENKINS_HOME/[DIR_name]/JUNIT_happypath.xml ]]; then
	cp -v $JENKINS_HOME/[DIR_name]/JUNIT_happypath.xml ${WORKSPACE}/[server_name]/[DIR_name]/JUNIT_happypath.xml
fi

# Create Package List
rpm -qa > ${WORKSPACE}/[server_name]/InstalledPackagesList.txt

# userslist.txt
while IFS= read -r var
do
	NAME=$var
	
    if [[ ! -e ${WORKSPACE}/[server_name]/users/$NAME ]]; then
    	mkdir -p ${WORKSPACE}/[server_name]/users/$NAME
		cp -rv /users/$NAME/config.xml ${WORKSPACE}/[server_name]/users/$NAME/config.xml
    fi

done < "userslist.txt"

# jenkins_install_scriptler_scripts.txt
while IFS= read -r var
do
	NAME=$var
	
    cp -rv /scriptler/scripts/$NAME ${WORKSPACE}/[server_name]/scriptler/scripts/$NAME

done < "jenkins_install_scriptler_scripts.txt"

# [DIR_name]Scripts.txt
while IFS= read -r var
do
	FILE_NAME=$var
    
    cp -rv ${FILE_NAME} ${WORKSPACE}/[server_name]${FILE_NAME}
    
done < "[DIR_name]Scripts.txt"

# [DIR_name]makeself.txt
while IFS= read -r var
do
	FILE_NAME=$var
    
    cp -rv ${FILE_NAME} ${WORKSPACE}/[server_name]${FILE_NAME}
    
done < "[DIR_name]makeself.txt"

# [DIR_name]flags.txt
while IFS= read -r var
do
	FILE_NAME=$var
    
    cp -rv ${FILE_NAME} ${WORKSPACE}/[server_name]${FILE_NAME}
    
done < "[DIR_name]shflags.txt"

# [DIR_name]Cas_Utils.txt
while IFS= read -r var
do
	FILE_NAME=$var
    
    cp -rv "/[DIR_name]/cas_utils/${FILE_NAME}" "${WORKSPACE}/[server_name]/[DIR_name]/cas_utils/${FILE_NAME}"
    
done < "[DIR_name]Cas_Utils.txt"

# userslist.txt
while IFS= read -r var
do
	NAME=$var
	
    if [[ ! -e ${WORKSPACE}/[server_name]/users/$NAME ]]; then
    	mkdir -p ${WORKSPACE}/[server_name]/users/$NAME
		cp -rv /users/$NAME/config.xml ${WORKSPACE}/[server_name]/users/$NAME/config.xml
    fi

done < "userslist.txt"

# [DIR_name][DIR_name]Customizations.txt
while IFS= read -r var
do
	FILE_NAME=$var
    temp=$(echo ${FILE_NAME%/*})
    if [[ ! -e "${WORKSPACE}/[server_name]${temp}" ]]; then
    	mkdir -p ${WORKSPACE}/[server_name]${temp}
    fi
		cp -rv "${FILE_NAME}" "${WORKSPACE}/[server_name]${FILE_NAME}"
    
done < "[DIR_name][DIR_name]Customizations.txt"