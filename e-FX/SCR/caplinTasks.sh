################################################################################
#!/bin/env bash
#
# Script for Executing Caplin Tasks
#
# Usage: caplinTasks.sh
#
# Author: Ramon Martin Lopez [ramn.martn@servexternos.isban.es]
# Since: 06/03/2015 
# Last Modified: 13/03/2015  (ramn.martn)
#
###############################################################################

# Stops Caplin
# Usage: caplinTasks.stopCaplin $1
# $1: $targetMachine
function caplinTasks.stopCaplin(){
	# Stop processes now
	caplinTasks.operateCaplin stop $1
	if [ $? = 0 ]; then
		utils.logResultOK "CAPLIN STOPPED SUCCESSFULLY IN $1 ###"
		RETVAL=0
	else 
		utils.logResultKO "CAPLIN FAILED TO STOP IN $1 ###"
		RETVAL=1
	fi	
}

# Starts Caplin
# Usage: caplinTasks.startCaplin $1
# $1: $targetMachine
function caplinTasks.startCaplin(){
	# Start processes now
	caplinTasks.operateCaplin start $1
	if [ $? = 0 ]; then
		utils.logResultOK "CAPLIN STARTED SUCCESSFULLY IN $1 ###"
		RETVAL=0
	else
		utils.logResultKO "CAPLIN FAILED TO START IN $1 ###"
		RETVAL=1
	fi	
}

# Shows Caplin Status
# Usage: caplinTasks.statusCaplin $1
# $1: $targetMachine
function caplinTasks.statusCaplin(){
	# Show processes status now
	caplinTasks.operateCaplin status $1
	if [ $? = 0 ]; then
		utils.logResultOK "CAPLIN STATUS SHOWED SUCCESSFULLY IN $1 ###"
		RETVAL=0
	else
		utils.logResultKO "CAPLIN STATUS FAILED TO SHOW IN $1 ###"
		RETVAL=1
	fi	
}

# Shows Caplin version
# Usage: caplinTasks.versionsCaplin $1
# $1: $targetMachine
function caplinTasks.versionsCaplin(){
	# Show processes version now
	caplinTasks.operateCaplin versions $1
	if [ $? = 0 ]; then
		utils.logResultOK "CAPLIN VERSIONS SHOWED SUCCESSFULLY IN $1 ###"
		RETVAL=0
	else
		utils.logResultKO "CAPLIN VERSIONS FAILED TO SHOW IN $1 ###"
		RETVAL=1
	fi	
}

# Operates Caplin
# Usage: caplinTasks.operateCaplin $1 $2
# $1: operation
# $2: $targetMachine
function caplinTasks.operateCaplin(){
	# operate the process
	declare -r REMOTE_CAPLIN_COMMAND="
		pushd /opt/caplin;
		./dfw \"$1\"; 
		popd;"
			
		#echo "$REMOTE_CAPLIN_COMMAND"
		if [ -z "$2" ]; then
			echo "Enter the Machine to operate ${ENV_MACHINES_SBANKD[5]} [1], ${ENV_MACHINES_SBANKD[6]} [2] >";
			read target_caplin
			case $target_caplin in
		        
		        1)
		        # ENV_MACHINES_SBANKD[5]
		        	TARGET_MACHINE="${ENV_MACHINES_SBANKD[5]}"
		        	;;
		        	
		        2)
		        # ENV_MACHINES_SBANKD[6
		        	TARGET_MACHINE="${ENV_MACHINES_SBANKD[6]}"
		        	;;
		        	
			esac  
		else TARGET_MACHINE="$2"
		fi
			      	
		ssh "$USER_CAPLIN@$TARGET_MACHINE" $REMOTE_CAPLIN_COMMAND
		if [ $? = 0 ]; then
			RETVAL=0
		else RETVAL=1
		fi	
}
