#AUTHOR: Pulkit
#Date: 06-Sept-2018
#Backup Jenkins server

I have added script called functions.sh which basks up various stuffs from Jenkins server like users, plugins, jobs, etc and from various jenkins server.
The user will have to check this script before calling.

Following scripts are present in repo:
1. functions.sh
	This is the main script where all the logic is written to copy the files or other stuff are taken care. It also checks and if there is no change in file which is already present then it will skip instead of overwriting.
2. Execute1.sh:
	This script handles to take backup of plugins and config.xml of jobs. Need to take care as it requires some parameters to execute.
3. jobs_CommitInGit.sh
	This script handles to take backup of newly created jobs only.
4. Execute2.sh:
	This script will create necessary folders and copy files from one particular server to appropriate folders in $WORKSPACE/[server_name]
5. Execute3.sh:
	This script will backup fstab, users, scripts, folders, credentials and other necessary files.
	
All the above mentioned scripts may or may not work as it is created for structure present in machines where it is used and users may need to update the scripts accordingly.
Also, please be careful to check before running.
