################################################################################
#!/bin/env bash
#
# Script for Executing Caplin Tasks
#
# Usage: caplinTasks.sh
#
# Author: Ramon Martin Lopez [ramn.martn@servexternos.isban.es]
# Since: 06/03/2015 
# Last Modified: 06/03/2015  (ramn.martn)
#
###############################################################################

# Stops Caplin
# Usage: caplinTasks.stopCaplin
function caplinTasks.stopCaplin(){
	# Stop processes now
	caplinTasks.operateCaplin stop
	utils.logResult "CAPLIN STOPPED SUCCESSFULLY ###"
}

# Starts Caplin
# Usage: caplinTasks.startCaplin
function caplinTasks.startCaplin(){
	# Start processes now
	caplinTasks.operateCaplin start
	utils.logResult "CAPLIN STARTED SUCCESSFULLY ###"
}

# Shows Caplin Status
# Usage: caplinTasks.statusCaplin
function caplinTasks.statusCaplin(){
	# Show processes status now
	caplinTasks.operateCaplin status
	utils.logResult "CAPLIN STATUS SHOWED SUCCESSFULLY ###"
}

# Shows Caplin version
# Usage: caplinTasks.versionCaplin
function caplinTasks.versionCaplin(){
	# Show processes version now
	caplinTasks.operateCaplin versions
	utils.logResult "CAPLIN VERSIONS SHOWED SUCCESSFULLY ###"
}

# Operates Caplin
# Usage: caplinTasks.operateCaplin $1
# $1: operation
function caplinTasks.operateCaplin(){
	# operate the process
	declare -r REMOTE_CAPLIN_COMMAND="
		pushd /opt/caplin;
		./dfw \"$1\"; 
		popd;"
			
		echo "$REMOTE_CAPLIN_COMMAND"	
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
		ssh "$USER_CAPLIN@$TARGET_MACHINE" $REMOTE_CAPLIN_COMMAND
}
