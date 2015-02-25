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

# Stars/Stops/Manages Processes
# Usage: maintenanceTasks.manageEFXProcess
function maintenanceTasks.manageEFXProcess(){
	utils.getTargetMachine
	echo "$TARGET_PROCESS, $TARGET_MACHINE, $TARGET_ENV";
	echo "Start[t], Stop[p], Show[w] >"
	read opt_efx_process_action
	case $opt_efx_process_action in
	        
	        t)
	        # START PROCESS
	        	option_picked_identified "you chose to Start $TARGET_PROCESS Process"
	        	maintenanceTasks.startProcess 2>>$EFX_INSTALLER_ERROR_FILE
	        	#showMaintenanceTasksMenu
	        	;;
	        	
	        p)
	        # STOP PROCESS
	        	option_picked_identified "you chose to Stop $TARGET_PROCESS Process"
	        	maintenanceTasks.stopProcess 2>>$EFX_INSTALLER_ERROR_FILE
	        	#showMaintenanceTasksMenu
	        	;;
	        	
	       	w)
	        # SHOW PROCESS
	        	option_picked_identified "you chose to Show $TARGET_PROCESS Process"
	        	maintenanceTasks.showProcess 2>>$EFX_INSTALLER_ERROR_FILE
	        	#showMaintenanceTasksMenu
	        	;; 		
	esac        	
	#ssh strmbase@"$TARGET_MACHINE" ls;
}

# Gets EFX processes related scripts 
# Usage: maintenanceTasks.getTargetScripts $1 $2
# $1: $TARGET_PROCESS
# $2: $TARGET_ENV
function maintenanceTasks.getTargetScripts(){

	for (( i = 0; i < ${#ENV_PROCESSES[@]}; i++ )); do
	   if [ "${ENV_PROCESSES[$i]}" = "$TARGET_PROCESS" ]; then
	       position=$i;
	   fi
	done
	case $position in
	        
	        1) 
	        	TARGET_SH_SCRIPT=adafix
	        	;;
	        	
	        2) 
	        	TARGET_SH_SCRIPT=adartenon
	        	;;
	        	
	       	3) 
	       		TARGET_SH_SCRIPT=adaxter; 
	       		TARGET_SH_SCRIPT_PRIMARY=primary-$TARGET_SH_SCRIPT; TARGET_SH_SCRIPT_SECONDARY=secondary-$TARGET_SH_SCRIPT
	        	;;	
	       	        	
	        4) 
	        	TARGET_SH_SCRIPT=agg
	        	;;
	        	        	
	        5) 
	        	TARGET_SH_SCRIPT=autoCMService
	        	;;
	        	        	
	        6) 
	        	TARGET_SH_SCRIPT=cleansing
	        	;;		
	        	        	        	
	        7) 
	        	TARGET_SH_SCRIPT=customerPricing; 
	        	TARGET_SH_SCRIPT_PRIMARY=primary-$TARGET_SH_SCRIPT; TARGET_SH_SCRIPT_SECONDARY=secondary-$TARGET_SH_SCRIPT
	        	;;
	        	        	        	
	        8) 
	        	TARGET_SH_SCRIPT=DashboardBridge
	        	TARGET_SH_SCRIPT_PRIMARY=primary-$TARGET_SH_SCRIPT; TARGET_SH_SCRIPT_SECONDARY=secondary-$TARGET_SH_SCRIPT
	        	;;
	        		        	        	        	
	        9) 
	        	TARGET_SH_SCRIPT=fwdPricing
	        	TARGET_SH_SCRIPT_PRIMARY=primary-$TARGET_SH_SCRIPT; TARGET_SH_SCRIPT_SECONDARY=secondary-$TARGET_SH_SCRIPT
	        	;;	
	        	        	        	
	        10) 
	        	TARGET_SH_SCRIPT=pricetenon
	        	TARGET_SH_SCRIPT_PRIMARY=primary-$TARGET_SH_SCRIPT; TARGET_SH_SCRIPT_SECONDARY=secondary-$TARGET_SH_SCRIPT
	        	;;	
	        		        	        	
	        11) 
	        	TARGET_SH_SCRIPT=corepricing
	        	;;	
	        		        	        	
	        12) 
	        	TARGET_SH_SCRIPT=tenorService
	        	;;	
	        		        		        	        	
	        13) 
	        	TARGET_SH_SCRIPT=newTickStore
	        	;;
	        		        		        	        	
	        14) 
	        	TARGET_SH_SCRIPT=tradeReports
	        	TARGET_SH_SCRIPT_PRIMARY=primary-$TARGET_SH_SCRIPT; TARGET_SH_SCRIPT_SECONDARY=secondary-$TARGET_SH_SCRIPT
	        	;;
	        		        		        	        	
	        15) 
	        	TARGET_SH_SCRIPT=trading
	        	TARGET_SH_SCRIPT_PRIMARY=primary-$TARGET_SH_SCRIPT; TARGET_SH_SCRIPT_SECONDARY=secondary-$TARGET_SH_SCRIPT
	        	;;
	        		        		        	        	
	        16) 
	        	TARGET_SH_SCRIPT=VOLHandler
	        	;;
	        		        		        	        	
	        17) 
	        	TARGET_SH_SCRIPT=CitiCombined
	        	;;
	        		        		        	        	
	        18) 
	        	TARGET_SH_SCRIPT=SFWDHandler.sh
	        	;;
	        		        		        	        	
	        19) 
	        	TARGET_SH_SCRIPT=DBCombined
	        	;;
	        		        		        	        	
	        20) 
	        	TARGET_SH_SCRIPT=DBFIX-Classic
	        	;;
	        		        		        	        	
	        21) 
	        	TARGET_SH_SCRIPT=DBFIX-Rapid
	        	;;
	        		        		        	        	
	        22) 
	        	TARGET_SH_SCRIPT=FIXCombined
	        	;;
	        		        		        	        	
	        23) 
	        	TARGET_SH_SCRIPT=GSCombined
	        	;;
	        		        		        		        	        	
	        24) 
	        	TARGET_SH_SCRIPT=MFHandler.sh
	        	;;	
	        	        		        		        	        	
	        25) 
	        	TARGET_SH_SCRIPT=TIHandler.sh
	        	;;
	        		        		        		        	        	
	        26) 
	        	TARGET_SH_SCRIPT=UBSCombined
	        	;;		
	        		        		        		        	        	
	 esac 
}

# Stops Process
# Usage: maintenanceTasks.stopProcess
function maintenanceTasks.stopProcess(){
	 #Find the machine where the process runs
	 #utils.getTargetMachine 
	 if [ "$TARGET_MACHINE" == "$(hostname)" ]; then
		 # Stop process now
		 # ./$1 stop
		 utils.logResult "Process: $TARGET_PROCESS in Machine: $TARGET_MACHINE stopped"
	 else
	 	#utils.logResult "Sorry you must stop the Process:$TARGET_PROCESS in Machine:$targetMachine"
	 	# ssh strmbase@"$TARGET_MACHINE" $1 stop
	 	maintenanceTasks.getTargetScripts; echo "$TARGET_SH_SCRIPT"
	 	ssh strmbase@"$TARGET_MACHINE" whoami;
	 	utils.logResult "Process:$TARGET_PROCESS in Machine:$TARGET_MACHINE stopped"
	 fi
}

# Starts Process
# Usage: maintenanceTasks.startProcess
function maintenanceTasks.startProcess(){
	 #Find the machine where the process runs
	 #utils.getTargetMachine 
	 if [ "$TARGET_MACHINE" == "$(hostname)" ]; then
		 # Start process now
		 #./$1 start
		 utils.logResult "Process:$TARGET_PROCESS in Machine:$TARGET_MACHINE started"
	 else
	 	# ssh strmbase@"$TARGET_MACHINE" $1 start
	 	maintenanceTasks.getTargetScripts; echo "$TARGET_SH_SCRIPT"
	 	ssh strmbase@"$TARGET_MACHINE" whoami;
	 	utils.logResult "Process:$TARGET_PROCESS in Machine:$TARGET_MACHINE started"	 
	 fi
}


# Asks status for Process
# Usage: maintenanceTasks.showProcess
function maintenanceTasks.showProcess(){
	 #Find the machine where the process runs
	 #utils.getTargetMachine 
	 if [ "$TARGET_MACHINE" == "$(hostname)" ]; then
		 # Show process now
		 #./$1 show
		 utils.logResult "Process:$TARGET_PROCESS in Machine:$TARGET_MACHINE showed"
	 else
	 	# ssh strmbase@"$TARGET_MACHINE" $1 show
	 	maintenanceTasks.getTargetScripts; echo "$TARGET_SH_SCRIPT"
	 	ssh strmbase@"$TARGET_MACHINE" whoami;
	 	utils.logResult "Process:$TARGET_PROCESS in Machine:$TARGET_MACHINE showed"	 
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