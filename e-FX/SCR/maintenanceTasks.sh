################################################################################
#!/bin/env bash
#
# Script for Executing other Maintenance Tasks
#
# Usage: maintenanceTasks.sh
#
# Author: Ramon Martin Lopez [ramn.martn@servexternos.isban.es]
# Since: 23/01/2015 
# Last Modified: 05/02/2015 (ramn.martn)
#
###############################################################################

# Añadir SSH
#Start LP Points Simulation in 'lnx-efxd38' host as 'strmbase' user
#http://www.linuxproblem.org/art_9.html
#http://www.octopuscs.com/blogs/Linux/How-to-avoid-entering-passwords-when-SSH-to-remote-machine

# Downloads software from URL
# Usage: maintenanceTasks.downloadEFX $1
# $1: URL/FILE to get the SW
# Tips: 4 Baxter you need credentials Usr:moob_juancarlos Passwd: pumby1012
# wget --dns-timeout=seconds, --connect-timeout=seconds, --read-timeout=seconds
function maintenanceTasks.downloadEFX(){
	DOWNLOAD_URLS_TMP=DOWNLOAD_URLS.in
	baxterArtifactoryUser="moob_juancarlos"
	baxterArtifactoryPasswd="pumby1012"
	baxterReleaseUser="santander"
	baxterReleasePasswd="EuWosDimlew1"
	# Ask for new Release details
	declare -x releaseFolder=''
	utils.ask4SWReleaseDetails releaseFolder
	# Create new Release Folder
	#echo -n "Release folder: $releaseFolder"
	utils.createNewFolder "$releaseFolder"
	echo -n "DOWNLOAD_URLS_TMP: $1"
	# Download the SW
	pushd "$releaseFolder"
	if [ -z "$1" ]; then
		echo -n "Please introduce URL to download, Ej.: http://host:port/path > "
		read downloadURL
		wget --user="$baxterArtifactoryUser" --password="$baxterArtifactoryPasswd" "$downloadURL" 2>&1 | tee -a $EFX_INSTALLER_LOG_FILE
	else 
		if [ "$1" == "$DOWNLOAD_URLS_TMP" ]; then
			wget --user="$baxterArtifactoryUser" --password="$baxterArtifactoryPasswd" --input-file="$EFX_INSTALLER_HOME/$DOWNLOAD_URLS_TMP" 2>&1 | tee -a $EFX_INSTALLER_LOG_FILE
		else
		 	wget --user="$baxterArtifactoryUser" --password="$baxterArtifactoryPasswd" --background "$1" 2>&1 | tee -a $EFX_INSTALLER_LOG_FILEç
		fi 	
	fi 
	OUT=$?
	if [ $OUT -eq 0 ]; then
		utils.logResult "Software from $downloadURL downloaded successfully"
	else 
		utils.logResult "Software from $downloadURL failed to download"
	fi
	popd
}

# Start LP Points Simulation
# Usage: maintenanceTasks.startSimulationPoints
function maintenanceTasks.startSimulationPoints(){
	#ssh -OPTIONS -p SSH_PORT user@remote_server "remote_command1; remote_command2; remote_script.sh" 
	#ssh strmbase@lnx-efxd38 /dev/shm/d3data/startServer.sh.NDF
	ENV_MACHINES_ALLOWED[0]=${ENV_MACHINES_EFXD[38]}
	utils.isAllowedHost hostAllowed
	ENV_MACHINES_ALLOWED=()	
	if  [ $hostAllowed = true ]; then
		# kill existing processes
		declare -i pPid1=$(ps -fu strmbase|grep startServer.sh.NDF|grep -v grep|awk '{print $2}')
		declare -i pPid2=$(ps -fu strmbase|grep /dev/shm/d3data/capture/demo/newDataNDF|grep -v grep|awk '{print $2}')
		kill -9 "$pPid1 $pPid2"
		utils.logResult "LP Points Simulation Process: $pPid1, $pPid2 Killed successfully"
		# start it
		pushd "/dev/shm/d3data"
		./startServer.sh.NDF
		utils.logResult "LP Points Simulation Process: $pPid1, $pPid2 Started successfully"
		popd
	fi	
}

# Change LP Points Simulation File
# Usage: maintenanceTasks.changeSimulationPointsFile
# Tips: REMEMBER juancp.awk file must be Changed first
function maintenanceTasks.changeSimulationPointsFile(){
	ENV_MACHINES_ALLOWED[0]=${ENV_MACHINES_EFXD[38]}
	utils.isAllowedHost hostAllowed
	ENV_MACHINES_ALLOWED=()	
	if  [ $hostAllowed = true ]; then
		utils.logResult "REMEMBER: juancp.awk file must be Changed first"
		declare -x now=$(date +"%Y-%m-%d-%H:%M:%S")
		# Backup newDataNDF file
		pushd "/dev/shm/d3data/capture/demo"
		cp newDataNDF newDataNDF.$now.bak
		# Transform the Prices file
		awk -f juancp.awk newDataNDF
		cp newDataNDF.new newDataNDF
		popd
		utils.logResult "LP Points Simulation File : Changed successfully"
	fi	
}

# Find log files bigger than 2GB
# Usage: maintenanceTasks.findBigLogs
function maintenanceTasks.findBigLogs(){
	utils.logResult "$(find /logs/strmbase/CerebroLogs -name *.log -type f -size +2048M -printf '%s %p\n'| sort -nr)"
}

# Stops Process
# Usage: maintenanceTasks.stopProcess
function maintenanceTasks.stopProcess(){
	 #Find the machine where the process runs
	 utils.getTargetMachine 
	 if [ "$TARGET_MACHINE" == "$(hostname)" ]; then
		 # Stop process now
		 # ./$1 stop
		 utils.logResult "Process: $TARGET_PROCESS in Machine: $TARGET_MACHINE stopped"
	 else
	 	utils.logResult "Sorry you must stop the Process: $TARGET_PROCESS in Machine: $targetMachine"	 
	 fi
}

# Starts Process
# Usage: maintenanceTasks.startProcess
function maintenanceTasks.startProcess(){
	 #Find the machine where the process runs
	 utils.getTargetMachine 
	 if [ "$TARGET_MACHINE" == "$(hostname)" ]; then
		 # Start process now
		 #./$1 start
		 utils.logResult "Process: $TARGET_PROCESS in Machine: $TARGET_MACHINE started"
	 else
	 	utils.logResult "Sorry you must start the Process: $TARGET_PROCESS in Machine: $targetMachine"	 
	 fi
}


# Asks status for Process
# Usage: maintenanceTasks.showProcess
function maintenanceTasks.showProcess(){
	 #Find the machine where the process runs
	 utils.getTargetMachine 
	 if [ "$TARGET_MACHINE" == "$(hostname)" ]; then
		 # Show process now
		 #./$1 show
		 utils.logResult "Process: $TARGET_PROCESS in Machine: $TARGET_MACHINE showed"
	 else
	 	utils.logResult "Sorry you must show the Process: $TARGET_PROCESS in Machine: $targetMachine"	 
	 fi
}

# Asks status for Process
# Usage: maintenanceTasks.signRPMs
function maintenanceTasks.signRPMs(){
	# Ask for new Release details
	declare -x releaseFolder=''
	utils.ask4SWReleaseDetails releaseFolder
	# Sign RPMs
	pushd "$releaseFolder"
	rpmsToSign=$(ls | grep rpm | awk '{ ORS=" "; print; }')
	echo -n "$rpmsToSign"
	$EFX_INSTALLER_HOME/rpmSign.exp $rpmsToSign | tee --append $EFX_INSTALLER_LOG_FILE
	popd
}