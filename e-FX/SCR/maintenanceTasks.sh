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
			#declare -i pPid1=$(ps -fu strmbase|grep startServer.sh.NDF|grep -v grep|awk '{print $2}');
			#declare -i pPid2=$(ps -fu strmbase|grep /dev/shm/d3data/capture/demo/newDataNDF|grep -v grep|awk '{print $2}');
			#kill -9 "$pPid1 $pPid2";
			#ps -fu strmbase|grep sink_driven_src|grep -v grep|awk '{print $2}'|xargs kill;
			#pushd /dev/shm/d3data;
			#./startServer.sh.NDF.20;
		echo "Enter Update Rate: >"
		read updateRate	
		declare -x REMOTE_COMMAND="
			killall -9 sink_driven_src;
			pushd "/dev/shm/d3data/replay/demo";
			export LD_LIBRARY_PATH=.;
			nohup ./sink_driven_src -S SFWD -c -I 1 -E sslauto -Q /dev/shm/d3data/capture/demo/newDataNDF -K -N 8105 -U $updateRate >/dev/null 2>&1 ;
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
	find /logs -name '*.out' -type f -size +2000M -printf '%p\n'| sort -nr >>$BIG_LOG_FILES
	find /local/home/strmbase -name '*.log' -type f -size +2000M -printf '%p\n'| sort -nr >>$BIG_LOG_FILES
	find /local/home/strmbase -name '*.out' -type f -size +2000M -printf '%p\n'| sort -nr >>$BIG_LOG_FILES
	if [[ -s $BIG_LOG_FILES ]]; then
		utils.logResult "$(cat $BIG_LOG_FILES) found"
		RETVAL=0
	else 
		utils.logResult "No Big log Files found"
		RETVAL=1	
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
				RETVAL=0
			else 	
				utils.logResult "$filename could not be removed"
				RETVAL=1
			fi
		done < $BIG_LOG_FILES
	else 
		utils.logResult "No Big log files found" 
		RETVAL=0
	fi
}

# Stars/Stops/Manages EFX Processes
# Usage: maintenanceTasks.manageEFXProcess
function maintenanceTasks.manageEFXProcess(){
	# get Target configuration
	utils.getTargetMachine
	#echo "$TARGET_PROCESS, $TARGET_MACHINE, $TARGET_ENV";
	if [ "$TARGET_PROCESS" == "eFX-Adaxter" ] || [ "$TARGET_PROCESS" == "eFX-RFQAdaxter" ] || [ "$TARGET_PROCESS" == "eFX-DashboardBridge" ] ||
	 [ "$TARGET_PROCESS" == "eFX-ForwardPricing" ] || [ "$TARGET_PROCESS" == "eFX-Pricetenon" ] || [ "$TARGET_PROCESS" == "eFX-TradeReports" ] || 
	 [ "$TARGET_PROCESS" == "eFX-Trading" ] || [ "$TARGET_PROCESS" == "eFX-CustomerPricing" ]; then 
		echo "Use: Primary[p], Secondary[s] >"
		read opt_efx_process_instance
	fi
	if [ "$TARGET_PROCESS" == 'eFX-Trading' ]; then	
		echo "Start[t], Stop[p], Show[w], Kill[k], Promote[l]  >"	
	else
		echo "Start[t], Stop[p], Show[w], Kill[k]  >"
	fi
	read opt_efx_process_action
	
	case $opt_efx_process_action in
	        
	        t)
	        # START PROCESS
	        	option_picked_identified "you chose to Start $TARGET_PROCESS Process"
	        	maintenanceTasks.operateEFXProcess start $opt_efx_process_instance 2>>$EFX_INSTALLER_ERROR_FILE
	        	if [ $RETVAL = 0 ]; then	
	        		utils.logResultOK "Process: $TARGET_PROCESS in Machine: $TARGET_MACHINE started"
	        	else
	        		utils.logResultKO "Process: $TARGET_PROCESS in Machine: $TARGET_MACHINE failed to start"
	        	fi
	        	sleep 2
	        	;;
	        	
	        p)
	        # STOP PROCESS
	        	option_picked_identified "you chose to Stop $TARGET_PROCESS Process"
	        	maintenanceTasks.operateEFXProcess stop $opt_efx_process_instance 2>>$EFX_INSTALLER_ERROR_FILE
	        	if [ $RETVAL = 0 ]; then
	        		utils.logResultOK "Process: $TARGET_PROCESS in Machine: $TARGET_MACHINE stopped"
	        	else
	        		utils.logResultKO "Process: $TARGET_PROCESS in Machine: $TARGET_MACHINE failed to stop"
	        	fi	
	        	sleep 2
	        	;;
	        	
	       	w)
	        # SHOW PROCESS
	        	option_picked_identified "you chose to Show $TARGET_PROCESS Process"
	        	if [ "$TARGET_PROCESS" == 'Baxter' ]; then
	        		echo "$TARGET_PROCESS"
	        	elif [ "$TARGET_PROCESS" == 'Caplin' ]; then
	        		echo "$TARGET_PROCESS"
	        	else
	        		maintenanceTasks.operateEFXProcess show $opt_efx_process_instance 2>>$EFX_INSTALLER_ERROR_FILE
	        		if [ $RETVAL = 0 ]; then
	        			utils.logResultOK "Process: $TARGET_PROCESS in Machine: $TARGET_MACHINE showed"
	        		else
	        			utils.logResultKO "Process: $TARGET_PROCESS in Machine: $TARGET_MACHINE failed to show"
	        		fi	
	        	fi	
	        	#sleep 2
	        	utils.listenConfirmation menus.maintenance.showMaintenanceTasksMenu menus.maintenance.listenMaintenanceTasksMenu
	        	;; 	
	       
	        k)
	        # KILL PROCESS
	        	option_picked_identified "you chose to Kill $TARGET_PROCESS Process"
	        	maintenanceTasks.operateEFXProcess kill $opt_efx_process_instance 2>>$EFX_INSTALLER_ERROR_FILE
	        	if [ $RETVAL = 0 ]; then
	        		utils.logResultOK "Process: $TARGET_PROCESS in Machine: $TARGET_MACHINE killed"
	        	else
	        		utils.logResultKO "Process: $TARGET_PROCESS in Machine: $TARGET_MACHINE failed to kill"
	        	fi
	        	#sleep 2
	        	utils.listenConfirmation menus.maintenance.showMaintenanceTasksMenu menus.maintenance.listenMaintenanceTasksMenu
	        	;; 	
	        	
	        l)
	        # TRADING LEADERSHIP
	        	option_picked_identified "you chose to Change $TARGET_PROCESS Trading Leadership"
	        	maintenanceTasks.operateEFXProcess "promote 1" $opt_efx_process_instance 2>>$EFX_INSTALLER_ERROR_FILE
	        	if [ $RETVAL = 0 ]; then
	        		utils.logResultOK "Process: $TARGET_PROCESS in Machine: $TARGET_MACHINE Promoted to Leader"
	        	else
	        		utils.logResultKO "Process: $TARGET_PROCESS in Machine: $TARGET_MACHINE failed to Promote to Leader"
	        	fi
	        	#sleep 2
	        	utils.listenConfirmation menus.maintenance.showMaintenanceTasksMenu menus.maintenance.listenMaintenanceTasksMenu
	        	;; 	
	esac        	
}

# Search BUS for Prices
# Usage: maintenanceTasks.search4Prices
function maintenanceTasks.search4Prices(){
	# get Target configuration
	utils.getTargetMachine4LP
	#echo "$TARGET_PROCESS, $TARGET_MACHINE, $TARGET_ENV";
	TARGET_PATH_SCRIPT=/local/home/strmbase/global/scripts
	for (( i = 0; i < ${#EFX_ENVIRONMENTS[@]}; i++ )); do
	   if [ "${EFX_ENVIRONMENTS[$i]}" = "$TARGET_ENV" ]; then
	       position=$i;
	   fi
	 done
	 case $position in 
	 
			1) 
				#DEV1
	        	TARGET_SH_SCRIPT=rv-dev1-all
				;;	
				
			2) 
				#DEV3
	        	TARGET_SH_SCRIPT=rv-dev3-all
				;;		
							
			3) 
				#DEV4
	        	TARGET_SH_SCRIPT=rv-dev4-all
				;;
				
			4) 
				#SIT1
				TARGET_SH_SCRIPT=rv-sit-all	
				;;	
				
			5) 
				#SIT2
				TARGET_SH_SCRIPT=rv-sit2-all	
				;;
				
			6) 
				#CAPLIN
	        	TARGET_SH_SCRIPT=rv-caplin-all
				;;	
	
	esac
	
	# operate the process
	declare -r REMOTE_EFX_LP_COMMAND="
		pushd \"$TARGET_PATH_SCRIPT\";
		./\"$TARGET_SH_SCRIPT\" | grep RAW; 
		popd;"
	
	echo "$REMOTE_EFX_LP_COMMAND"			
	ssh "$USER_STRMBASE@$TARGET_MACHINE" $REMOTE_EFX_PROCESS_COMMAND
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
	 if [ "$1" == "promote 1" ]; then
	 	TARGET_SH_SCRIPT="$TARGET_SH_TRADING_PROMOTE_SCRIPT"
	 fi
	 if [ -n "$TARGET_SH_SCRIPT" ] && [ "$TARGET_SH_SCRIPT" != 'Baxter' ] && [ "$TARGET_SH_SCRIPT" != 'Caplin' ]; then
		 	# Check the TIBCO port is free
		 	declare -r REMOTE_EFX_PROCESS_FREE="netstat -putan | grep \"$TARGET_PORT\" |grep LISTEN |awk '{print $7}' |awk -F "/" '{print $1}'|xargs kill;"
		 	# operate the process
		 	declare -r REMOTE_EFX_PROCESS_COMMAND="
		 		. .bash_profile;
		 		cd \"$TARGET_PATH_SCRIPT\";
				. \"$TARGET_ENV_SCRIPT\"; 
				./\"$TARGET_SH_SCRIPT\" \"$1\";
				exitcode=\$?;
				if [ \$exitcode = 0 ]; then
					echo 'Command SUCCESS';
				else
					echo 'Command FAILURE';
				fi;
				exit \$exitcode;"
			
			#echo "$REMOTE_EFX_PROCESS_COMMAND"	
		 	ssh "$USER_STRMBASE@$TARGET_MACHINE" $REMOTE_EFX_PROCESS_COMMAND
		 	if [ $? = 0 ]; then
		 		RETVAL=0
		 	else
		 		RETVAL=1
		 	fi
	 else 
		utils.logResult "Process:$TARGET_PROCESS in Machine:$TARGET_MACHINE not found"
		RETVAL=1
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
	       		TARGET_SH_SCRIPT=RFQadaxter; 
	       		TARGET_SH_SCRIPT_PRIMARY=primary-$TARGET_SH_SCRIPT; TARGET_SH_SCRIPT_SECONDARY=secondary-$TARGET_SH_SCRIPT
	        	;;
	        	   	
	        5) 
	        	TARGET_SH_SCRIPT=agg
	        	;;
	        	        	
	        6) 
	        	TARGET_SH_SCRIPT=autoCMService
	        	;;
	        	        	
	        7) 
	        	TARGET_SH_SCRIPT=cleansing
	        	;;		
	        	        	        	
	        8) 
	        	TARGET_SH_SCRIPT=customerPricing; 
	        	TARGET_SH_SCRIPT_PRIMARY=primary-$TARGET_SH_SCRIPT; TARGET_SH_SCRIPT_SECONDARY=secondary-$TARGET_SH_SCRIPT
	        	;;
	        	        	        	
	        9) 
	        	TARGET_SH_SCRIPT=DashboardBridge
	        	TARGET_SH_SCRIPT_PRIMARY=primary-$TARGET_SH_SCRIPT; TARGET_SH_SCRIPT_SECONDARY=secondary-$TARGET_SH_SCRIPT
	        	;;
	        		        	        	        	
	        10) 
	        	TARGET_SH_SCRIPT=fwdPricing
	        	TARGET_SH_SCRIPT_PRIMARY=primary-$TARGET_SH_SCRIPT; TARGET_SH_SCRIPT_SECONDARY=secondary-$TARGET_SH_SCRIPT
	        	;;	
	        	        	        	
	        11) 
	        	TARGET_SH_SCRIPT=pricetenon
	        	TARGET_SH_SCRIPT_PRIMARY=primary-$TARGET_SH_SCRIPT; TARGET_SH_SCRIPT_SECONDARY=secondary-$TARGET_SH_SCRIPT
	        	;;	
	        		        	        	
	        12) 
	        	TARGET_SH_SCRIPT=corepricing
	        	;;	
	        		        	        	
	        13) 
	        	TARGET_SH_SCRIPT=tenorService
	        	;;	
	        		        		        	        	
	        14) 
	        	TARGET_SH_SCRIPT=newTickStore
	        	;;
	        		        		        	        	
	        15) 
	        	TARGET_SH_SCRIPT=tradeReports
	        	TARGET_SH_SCRIPT_PRIMARY=primary-$TARGET_SH_SCRIPT; TARGET_SH_SCRIPT_SECONDARY=secondary-$TARGET_SH_SCRIPT
	        	;;
	        		        		        	        	
	        16) 
	        	TARGET_SH_SCRIPT=trading
	        	TARGET_SH_SCRIPT_PRIMARY=primary-$TARGET_SH_SCRIPT; TARGET_SH_SCRIPT_SECONDARY=secondary-$TARGET_SH_SCRIPT
	        	TARGET_SH_TRADING_PROMOTE_SCRIPT=tradingLeadership.sh
	        	;;
	        		        		        	        	
	        17) 
	        	TARGET_SH_SCRIPT=VOLHandler
	        	;;
	        		        		        	        	
	        18) 
	        	TARGET_SH_SCRIPT=CitiCombined
	        	;;
	        		        		        	        	
	        19) 
	        	TARGET_SH_SCRIPT=SFWDHandler.sh
	        	;;
	        		        		        	        	
	        20) 
	        	TARGET_SH_SCRIPT=DBCombined
	        	;;
	        		        		        	        	
	        21) 
	        	TARGET_SH_SCRIPT=DBFIX-Classic
	        	;;
	        		        		        	        	
	        22) 
	        	TARGET_SH_SCRIPT=DBFIX-Rapid
	        	;;
	        		        		        	        	
	        23) 
	        	TARGET_SH_SCRIPT=FIXCombined
	        	;;
	        		        		        	        	
	        24) 
	        	TARGET_SH_SCRIPT=GSCombined
	        	;;
	        		        		        		        	        	
	        25) 
	        	TARGET_SH_SCRIPT=MFHandler.sh
	        	;;	
	        	        		        		        	        	
	        26) 
	        	TARGET_SH_SCRIPT=TIHandler.sh
	        	;;
	        		        		        		        	        	
	        27) 
	        	TARGET_SH_SCRIPT=UBSCombined
	        	;;
	        	        	        		        		        		        	        	
	        28) 
	        	TARGET_SH_SCRIPT=Baxter
	        	;;			
	        	        		        		        		        	        	
	        29) 
	        	TARGET_SH_SCRIPT=Caplin
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
				#DEV4
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