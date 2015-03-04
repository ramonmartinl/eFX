################################################################################
#!/bin/env bash
#
# Script for Executing other Maintenance Tasks
#
# Usage: maintenanceTasks.sh
#
# Author: Ramon Martin Lopez [ramn.martn@servexternos.isban.es]
# Since: 23/01/2015 
# Last Modified: 27/02/2015 (ramn.martn)
#
###############################################################################

declare -r BIG_LOG_FILES=bigLogs.out

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
		 	wget --user="$baxterArtifactoryUser" --password="$baxterArtifactoryPasswd" --background "$1" 2>&1 | tee -a $EFX_INSTALLER_LOG_FILE�
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
			#declare -i pPid1=$(ps -fu strmbase|grep startServer.sh.NDF|grep -v grep|awk '{print $2}');
			#declare -i pPid2=$(ps -fu strmbase|grep /dev/shm/d3data/capture/demo/newDataNDF|grep -v grep|awk '{print $2}');
			#kill -9 "$pPid1 $pPid2";
			#ps -fu strmbase|grep startServer.sh.NDF|grep -v grep|awk '{print $2}'|xargs kill;
			#ps -fu strmbase|grep /dev/shm/d3data/capture/demo/newDataNDF|grep -v grep|awk '{print $2}'|xargs kill;
			#pushd /dev/shm/d3data;
			#./startServer.sh.NDF.20;
		echo "Enter Update Rate: >"
		read updateRate	
		declare -x REMOTE_COMMAND="
			killall -9 sink_driven_src
			pushd /dev/shm/d3data/replay/demo;
			export LD_LIBRARY_PATH=.;
			./sink_driven_src -S SFWD -c -I 1 -E sslauto -Q /dev/shm/d3data/capture/demo/newDataNDF -K -N 8105 -U \"$updateRate\";
			popd;"
			
		ssh "$USER_STRMBASE@${ENV_MACHINES_EFXD[38]}" $REMOTE_COMMAND
		utils.logResult "LP Points Simulation Process: $pPid1, $pPid2 Started successfully"
}

# Change LP Points Simulation File
# Usage: maintenanceTasks.changeSimulationPointsFile
# Tips: REMEMBER juancp.awk file must be Changed first
function maintenanceTasks.changeSimulationPointsFile(){
		utils.logResult "REMEMBER: changeNewDataNDF.awk file must be Changed first"
		declare -x REMOTE_COMMAND="
			pushd "/dev/shm/d3data/capture/demo";
			cp newDataNDF newDataNDF.$(date +"%Y-%m-%d-%H-%M-%S").bak;
			awk -f changeNewDataNDF.awk newDataNDF;
			cp newDataNDF.new newDataNDF;
			popd;"
		
		ssh "$USER_STRMBASE@${ENV_MACHINES_EFXD[38]}" $REMOTE_COMMAND
		utils.logResult "LP Points Simulation File : Changed successfully"
}

# Find log files bigger than 2GB
# Usage: maintenanceTasks.findBigLogs
function maintenanceTasks.findBigLogs(){
	touch $BIG_LOG_FILES
	find /logs -name '*.log' -type f -size +2000M -printf '%p\n'| sort -nr >$BIG_LOG_FILES
	if [[ -s $BIG_LOG_FILES ]]; then
		utils.logResult "$(cat $BIG_LOG_FILES) found"
	fi	
}

# Removes log files bigger than 2GB
# Usage: maintenanceTasks.removeBigLogs
# Hint: you must remove processes first
function maintenanceTasks.removeBigLogs(){
	maintenanceTasks.findBigLogs
	if [[ -s $BIG_LOG_FILES ]]; then
		while read -r filename; do
	  		rm "$filename"
			if [ $? -eq 0 ]; then
				utils.logResult "$filename removed successfully"
			else 	
				utils.logResult "$filename could not be removed"
			fi
		done < $BIG_LOG_FILES
	else utils.logResult "No Big log files found" 	
	fi
}

# Stars/Stops/Manages Processes
# Usage: maintenanceTasks.manageEFXProcess
function maintenanceTasks.manageEFXProcess(){
	utils.getTargetMachine
	#echo "$TARGET_PROCESS, $TARGET_MACHINE, $TARGET_ENV";
	if [ "$TARGET_PROCESS" == "eFX-Adaxter" ] || [ "$TARGET_PROCESS" == "eFX-CustomerPricing" ] || [ "$TARGET_PROCESS" == "eFX-DashboardBridge" ] ||
	 [ "$TARGET_PROCESS" == "eFX-ForwardPricing" ] || [ "$TARGET_PROCESS" == "eFX-Pricetenon" ] || [ "$TARGET_PROCESS" == "eFX-TradeReports" ] || 
	 [ "$TARGET_PROCESS" == "eFX-Trading" ]; then 
		echo "Use: Primary[p], Secondary[s] >"
		read opt_efx_process_instance
	fi
	echo "Start[t], Stop[p], Show[w], Kill[k]  >"
	read opt_efx_process_action
	
	case $opt_efx_process_action in
	        
	        t)
	        # START PROCESS
	        	option_picked_identified "you chose to Start $TARGET_PROCESS Process"
	        	maintenanceTasks.operateEFXProcess start $opt_efx_process_instance 2>>$EFX_INSTALLER_ERROR_FILE
	        	utils.logResult "Process: $TARGET_PROCESS in Machine: $TARGET_MACHINE started"
	        	sleep 2
	        	;;
	        	
	        p)
	        # STOP PROCESS
	        	option_picked_identified "you chose to Stop $TARGET_PROCESS Process"
	        	maintenanceTasks.operateEFXProcess stop $opt_efx_process_instance 2>>$EFX_INSTALLER_ERROR_FILE
	        	utils.logResult "Process: $TARGET_PROCESS in Machine: $TARGET_MACHINE stopped"
	        	sleep 2
	        	;;
	        	
	       	w)
	        # SHOW PROCESS
	        	option_picked_identified "you chose to Show $TARGET_PROCESS Process"
	        	maintenanceTasks.operateEFXProcess show $opt_efx_process_instance 2>>$EFX_INSTALLER_ERROR_FILE
	        	utils.logResult "Process: $TARGET_PROCESS in Machine: $TARGET_MACHINE showed"
	        	#sleep 2
	        	utils.listenConfirmation menus.maintenance.showMaintenanceTasksMenu menus.maintenance.listenMaintenanceTasksMenu
	        	;; 	
	       
	        k)
	        # KILL PROCESS
	        	option_picked_identified "you chose to Kill $TARGET_PROCESS Process"
	        	maintenanceTasks.operateEFXProcess kill $opt_efx_process_instance 2>>$EFX_INSTALLER_ERROR_FILE
	        	utils.logResult "Process: $TARGET_PROCESS in Machine: $TARGET_MACHINE killed"
	        	#sleep 2
	        	utils.listenConfirmation menus.maintenance.showMaintenanceTasksMenu menus.maintenance.listenMaintenanceTasksMenu
	        	;; 		
	esac        	
}

# Stops/Starts/Shows Process
# Usage: maintenanceTasks.operateEFXProcess $1 $2
# $1: operation to do
# $2: Primary/Secondary
# Hint: ssh -OPTIONS -p SSH_PORT user@remote_server "remote_command1; remote_command2; remote_script.sh" 
function maintenanceTasks.operateEFXProcess(){
	 maintenanceTasks.getTargetScripts; #echo "Path: $TARGET_PATH_SCRIPT, Environment: $TARGET_ENV_SCRIPT, primary: $TARGET_SH_SCRIPT_PRIMARY, secondary:  $TARGET_SH_SCRIPT_SECONDARY, Command: $TARGET_SH_SCRIPT"
	 if [ -n "$TARGET_SH_SCRIPT_PRIMARY" ] && [ "$2" == "p" ]; then
	 	 TARGET_SH_SCRIPT=$TARGET_SH_SCRIPT_PRIMARY
	 fi
	 if [ -n "$TARGET_SH_SCRIPT_SECONDARY" ] && [ "$2" == "s" ]; then
	 	 TARGET_SH_SCRIPT=$TARGET_SH_SCRIPT_SECONDARY
	 fi 
	 if [ -n "$TARGET_SH_SCRIPT" ]; then
		if [ "$TARGET_MACHINE" == "$(hostname)" ]; then
			 # Operate process now
			 # . $1 ./$2 $3
			 echo "TEST"
		 else
		 	# Check the TIBCO port is free
		 	declare -r REMOTE_EFX_PROCESS_FREE="netstat -putan | grep \"$TARGET_PORT\" |grep LISTEN |awk '{print $7}' |awk -F "/" '{print $1}'|xargs kill;"
		 	# operate the process
		 	declare -r REMOTE_EFX_PROCESS_COMMAND="
		 		pushd \"$TARGET_PATH_SCRIPT\";
				. \"$TARGET_ENV_SCRIPT\"; 
				./\"$TARGET_SH_SCRIPT\" \"$1\"; 
				popd"
				
		 	ssh "$USER_STRMBASE@$TARGET_MACHINE" $REMOTE_EFX_PROCESS_COMMAND
		 fi
	 else 
		utils.logResult "Process:$TARGET_PROCESS in Machine:$TARGET_MACHINE not found"
	 fi
}

# Gets EFX processes related scripts 
# Usage: maintenanceTasks.getTargetScripts
function maintenanceTasks.getTargetScripts(){

	TARGET_SH_SCRIPT=''
	TARGET_ENV_SCRIPT=''
	TARGET_SH_SCRIPT_PRIMARY=''; TARGET_SH_SCRIPT_SECONDARY=''
	for (( i = 0; i < ${#EFX_PROCESSES[@]}; i++ )); do
	   if [ "${EFX_PROCESSES[$i]}" = "$TARGET_PROCESS" ]; then
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
	 
	 for (( j = 0; j < ${#EFX_ENVIRONMENTS[@]}; j++ )); do
	   if [ "${EFX_ENVIRONMENTS[$j]}" = "$TARGET_ENV" ]; then
	       position=$j;
	   fi
	 done
	 declare -x isLP=$(echo "$TARGET_PROCESS" | grep 'eFX-LP');
	 case $position in 
	 
			1) 
				#DEV1
				TARGET_PATH_SCRIPT=/local/home/strmbase/EFX-dev1/Linux/scripts
	        	TARGET_ENV_SCRIPT=env_dev1.sh
				;;	
				
			2) 
				#DEV3
				TARGET_PATH_SCRIPT=/local/home/strmbase/EFX-dev3/Linux/scripts
	        	TARGET_ENV_SCRIPT=env_dev3.sh
				;;		
							
			3) 
				#DEV5
				TARGET_PATH_SCRIPT=/local/home/strmbase/EFX-dev4/Linux/scripts
	        	TARGET_ENV_SCRIPT=env_dev4.sh
				;;
				
			4) 
				#SIT1
				if [ -z $isLP ] || [ "$TARGET_PROCESS" == 'eFX-LP-D3' ] || [ "$TARGET_PROCESS" == 'eFX-LP-MTI' ]; then
					TARGET_PATH_SCRIPT=/local/home/strmbase/EFX-all/Linux/scripts
	        		TARGET_ENV_SCRIPT=env_sit.sh
				else
		        	if [ -n $isLP ] && [ "$TARGET_PROCESS" != 'eFX-LP-D3' ] && [ "$TARGET_PROCESS" != 'eFX-LP-MTI' ]; then
		        		TARGET_PATH_SCRIPT=/local/home/strmbase/EFX-lp/Linux/scripts
		        		TARGET_ENV_SCRIPT=env_sit_lp.sh
		        	fi
		        fi	
				;;	
				
			5) 
				#SIT2
				if [ -z $isLP ] || [ "$TARGET_PROCESS" == 'eFX-LP-D3' ] || [ "$TARGET_PROCESS" == 'eFX-LP-MTI' ]; then
					TARGET_PATH_SCRIPT=/local/home/strmbase/EFX-all2/Linux/scripts
	        		TARGET_ENV_SCRIPT=env_sit2_sb7.sh
	        	else	
		        	if [ -n $isLP ] && [ "$TARGET_PROCESS" != 'eFX-LP-D3' ] && [ "$TARGET_PROCESS" != 'eFX-LP-MTI' ]; then
		        		TARGET_PATH_SCRIPT=/local/home/strmbase/EFX-lp2/Linux/scripts
		        		TARGET_ENV_SCRIPT=env_sit_lp.sh
		        	fi
		        fi	
				;;
				
			6) 
				#CAPLIN
				TARGET_PATH_SCRIPT=/local/home/strmbase/EFX-all-Caplin/Linux/scripts
	        	TARGET_ENV_SCRIPT=env_caplin.sh
				;;	
																        		        		        		        	        	
	 esac
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