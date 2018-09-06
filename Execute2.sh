#!/bin/bash

#Author: Pulkit
#Date: 06-Sept-2018
#Description: This script will create necessary folders and copy files from one particular server to appropriate folders in $WORKSPACE/[server_name] and upload

source backupJenkins/scripts/functions.sh

# Create [server_name] folder if not exist.
if [[ ! -e ${WORKSPACE}/[server_name] ]]; then
	mkdir -p ${WORKSPACE}/[server_name]
fi

if [[ ! -e ${WORKSPACE}/[server_name]/etc/sysconfig/network-scripts ]]; then
	mkdir -p ${WORKSPACE}/[server_name]/etc/sysconfig/network-scripts
fi

if [[ ! -e ${WORKSPACE}/[server_name]/etc/dhcp ]]; then
	mkdir -p ${WORKSPACE}/[server_name]/etc/dhcp
fi

if [[ ! -e ${WORKSPACE}/[server_name]/var/named ]]; then
	mkdir -p ${WORKSPACE}/[server_name]/var/named
fi

echo "Copying files from [server_name] to $WORKSPACE/[server_name] folder"
scp [username]@[server_name]:"/tmp/iptables /etc/fstab /etc/dhcp/dhcpd.conf /tmp/named.conf /tmp/[domain_name] /tmp/[IP] /etc/passwd /etc/sysconfig/network-scripts/ifcfg-eth0 /etc/sysconfig/network-scripts/ifcfg-eth1 /etc/resolv.conf /tmp/InstalledPackagesList.txt" ${WORKSPACE}/[server_name]

mv -v ${WORKSPACE}/[server_name]/iptables ${WORKSPACE}/[server_name]/etc/sysconfig/iptables
mv -v ${WORKSPACE}/[server_name]/fstab ${WORKSPACE}/[server_name]/etc/fstab
mv -v ${WORKSPACE}/[server_name]/dhcpd.conf ${WORKSPACE}/[server_name]/etc/dhcp/dhcpd.conf
mv -v ${WORKSPACE}/[server_name]/named.conf ${WORKSPACE}/[server_name]/etc/named.conf
mv -v ${WORKSPACE}/[server_name]/[domain_name] ${WORKSPACE}/[server_name]/var/named/[domain_name]
mv -v ${WORKSPACE}/[server_name]/[IP] ${WORKSPACE}/[server_name]/var/named/[IP]
mv -v ${WORKSPACE}/[server_name]/passwd ${WORKSPACE}/[server_name]/etc/passwd
mv -v ${WORKSPACE}/[server_name]/ifcfg-eth0 ${WORKSPACE}/[server_name]/etc/sysconfig/network-scripts/ifcfg-eth0
mv -v ${WORKSPACE}/[server_name]/ifcfg-eth1 ${WORKSPACE}/[server_name]/etc/sysconfig/network-scripts/ifcfg-eth1
mv -v ${WORKSPACE}/[server_name]/resolv.conf ${WORKSPACE}/[server_name]/etc/resolv.conf

# Check if IPTABLES present else copy. If present, then compare and update if required.
CopyOrCompare [server_name]/etc/sysconfig/iptables ${DIR_GIT}/machines/[server_name]/etc/sysconfig/iptables "n" $NEW_LIST $NEW_NAME $DIFF_LIST $DIFF_NAME "y" "n"

# Check if MOUNT_POINTS fstab present else copy. If present, then compare and update if required.
CopyOrCompare [server_name]/etc/fstab ${DIR_GIT}/machines/[server_name]/etc/fstab "n" $NEW_LIST $NEW_NAME $DIFF_LIST $DIFF_NAME "y" "n"

# Check if dhcp list file present else copy. If present, then compare and update if required.
CopyOrCompare [server_name]/etc/dhcp/dhcpd.conf ${DIR_GIT}/machines/[server_name]/etc/dhcp/dhcpd.conf "n" $NEW_LIST $NEW_NAME $DIFF_LIST $DIFF_NAME "y" "n"

# Check if DNS named.conf file present else copy. If present, then compare and update if required.
CopyOrCompare [server_name]/etc/named.conf ${DIR_GIT}/machines/[server_name]/etc/named.conf "n" $NEW_LIST $NEW_NAME $DIFF_LIST $DIFF_NAME "y" "n"

# Check if DNS named/[domain_name] present else copy. If present, then compare and update if required.
CopyOrCompare [server_name]/var/named/[domain_name] ${DIR_GIT}/machines/[server_name]/var/named/[domain_name] "n" $NEW_LIST $NEW_NAME $DIFF_LIST $DIFF_NAME "y" "n"

# Check if DNS named/[IP] present else copy. If present, then compare and update if required.
CopyOrCompare [server_name]/var/named/[IP] ${DIR_GIT}/machines/[server_name]/var/named/[IP] "n" $NEW_LIST $NEW_NAME $DIFF_LIST $DIFF_NAME "y" "n"

# Check if user list file present else copy. If present, then compare and update if required.
CopyOrCompare [server_name]/etc/passwd ${DIR_GIT}/machines/[server_name]/etc/passwd "n" $NEW_LIST $NEW_NAME $DIFF_LIST $DIFF_NAME "y" "n"

# Check if ifcfg-eth0 file present else copy. If present, then compare and update if required.
CopyOrCompare [server_name]/etc/sysconfig/network-scripts/ifcfg-eth0 ${DIR_GIT}/machines/[server_name]/etc/sysconfig/network-scripts/ifcfg-eth0 "n" $NEW_LIST $NEW_NAME $DIFF_LIST $DIFF_NAME "y" "n"

# Check if ifcfg-eth1 file present else copy. If present, then compare and update if required.
CopyOrCompare [server_name]/etc/sysconfig/network-scripts/ifcfg-eth1 ${DIR_GIT}/machines/[server_name]/etc/sysconfig/network-scripts/ifcfg-eth1 "n" $NEW_LIST $NEW_NAME $DIFF_LIST $DIFF_NAME "y" "n"

# Check Installed Packages list
CopyOrCompare [server_name]/InstalledPackagesList.txt ${DIR_GIT}/machines/[server_name]/InstalledPackagesList.txt "n" $NEW_LIST $NEW_NAME $DIFF_LIST $DIFF_NAME "y" "n"

# Check if resolv.conf present else copy. If present, then compare and update if required.
CopyOrCompare [server_name]/etc/resolv.conf ${DIR_GIT}/machines/[server_name]/etc/resolv.conf "n" $NEW_LIST $NEW_NAME $DIFF_LIST $DIFF_NAME "y" "n"

New_list="New_list_ns.txt"
Update_list="Update_list_ns.txt"

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
			echo "$(cat $ModifiedjobName), [server_name]" > $ModifiedjobName
        fi
    else
    	echo "[server_name]" > $ModifiedjobName
    fi
fi

if [[ -s ${NEW_LIST} ]]; then
	if [[ -s $NewjobName ]]; then
    	if [[ $(wc -w $NewjobName ) > 1 ]]; then
			echo "$(cat $NewjobName), [server_name]" > $NewjobName
        fi
    else
    	echo "[server_name]" > $NewjobName
    fi
fi

# Delete [server_name] folder from workspace
if [[ -e [server_name] ]]; then
	rm -r [server_name]
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