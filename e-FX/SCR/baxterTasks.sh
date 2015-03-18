################################################################################
#!/bin/env bash
#
# Script for Executing Baxter Tasks
#
# Usage: baxter.sh
#
# Author: Ramon Martin Lopez [ramn.martn@servexternos.isban.es]
# Since: 20/02/2015 
# Last Modified: 20/02/2015  (ramn.martn)
#
###############################################################################

# Stops Baxter
# Usage: baxterTasks.stopBaxter $1
# $1: $TARGET_MACHINE
function baxterTasks.stopBaxter(){
	# Stop processes now
	declare -x REMOTE_BAXTER_COMMAND="
		. .bash_profile;
		killall -u $USER_BAXTER;
		exitcode=\$?;
		if [ \$exitcode = 0 ]; then
			echo 'Command SUCCESS';
		else
			echo 'Command FAILURE';
		fi;
		exit \$exitcode;"
		
	 #kill -9 `ps -fu baxter|grep java|grep -v grep|awk '{print $2}'`
	 baxterTasks.operateBaxter "$REMOTE_BAXTER_COMMAND" "$1"
	 if [ $? -eq 0 ]; then
		utils.logResultOK "BAXTER STOPPED SUCCESSFULLY\n"
		if [ -z $1 ]; then
	 		utils.listenConfirmation menus.baxter.showBaxterTasksMenu menus.baxter.listenBaxterTasksMenu
	 	fi
		return 0
	 else
		utils.logResultKO "BAXTER FAILED TO STOP\n"
		if [ -z $1 ]; then
	 		utils.listenConfirmation menus.baxter.showBaxterTasksMenu menus.baxter.listenBaxterTasksMenu
	 	fi
		return 1
	 fi
}

# Starts Baxter Configuration Server
# Usage: baxterTasks.startBaxterConfigurationServer $1
# $1: $TARGET_MACHINE
function baxterTasks.startBaxterConfigurationServer(){
	# Start Configuration Server
	declare -x REMOTE_BAXTER_COMMAND="
		. .bash_profile;
		$BAXTER_HOME/bin/start-configuration-server --daemon;
		exitcode=\$?;
		if [ \$exitcode = 0 ]; then
			echo 'Command SUCCESS';
		else
			echo 'Command FAILURE';
		fi;
		exit \$exitcode;"
		
	#$BAXTER_HOME/bin/start-configuration-server --daemon &
	baxterTasks.operateBaxter "$REMOTE_BAXTER_COMMAND" "$1"
	if [ $? -eq 0 ]; then
		utils.logResultOK "BAXTER CONFIGUATION SERVER STARTED SUCCESSFULLY\n"
		if [ -z $1 ]; then
	 		utils.listenConfirmation menus.baxter.showBaxterTasksMenu menus.baxter.listenBaxterTasksMenu
	 	fi
		return 0
 	else
		utils.logResultKO "BAXTER CONFIGUATION SERVER FAILED TO START\n"
		if [ -z $1 ]; then
	 		utils.listenConfirmation menus.baxter.showBaxterTasksMenu menus.baxter.listenBaxterTasksMenu
	 	fi
		return 1
	fi
}

# Starts Baxter Price Engine DBServer
# Usage: baxterTasks.startBaxterDBServer $1
# $1: $TARGET_MACHINE
function baxterTasks.startBaxterDBServer(){
	# Start DB Server
	#/bin/bash -c '$BAXTER_HOME/bin/dbserver start'
	declare -x REMOTE_BAXTER_COMMAND="
		. .bash_profile;
		$BAXTER_HOME/bin/dbserver start;
		exitcode=\$?;
		if [ \$exitcode = 0 ]; then
			echo 'Command SUCCESS';
		else
			echo 'Command FAILURE';
		fi;
		exit \$exitcode;"
		
	#$BAXTER_HOME/bin/dbserver start
	baxterTasks.operateBaxter "$REMOTE_BAXTER_COMMAND" "$1"
	if [ $? -eq 0 ]; then
		utils.logResultOK "DB SERVER BAXTER CONFIGUATION SERVER STARTED SUCCESSFULLY\n"
		if [ -z $1 ]; then
	 		utils.listenConfirmation menus.baxter.showBaxterTasksMenu menus.baxter.listenBaxterTasksMenu
	 	fi
		return 0
 	else
		utils.logResultKO "DB SERVER BAXTER CONFIGUATION SERVER FAILED TO START\n"
		if [ -z $1 ]; then
	 		utils.listenConfirmation menus.baxter.showBaxterTasksMenu menus.baxter.listenBaxterTasksMenu
	 	fi
		return 1
	fi
}

# Starts Baxter Blotter Server
# Usage: baxterTasks.startBaxterBlotterServer $1
# $1: $TARGET_MACHINE
function baxterTasks.startBaxterBlotterServer(){
	# Start Blotter Server
	#/bin/bash -c '$BAXTER_HOME/bin/blotterserver start'
	declare -x REMOTE_BAXTER_COMMAND="
		. .bash_profile;
		$BAXTER_HOME/bin/blotterserver start;
		exitcode=\$?;
		if [ \$exitcode = 0 ]; then
			echo 'Command SUCCESS';
		else
			echo 'Command FAILURE';
		fi;
		exit \$exitcode;"
		
	#$BAXTER_HOME/bin/blotterserver start
	baxterTasks.operateBaxter "$REMOTE_BAXTER_COMMAND" "$1"
	if [ $? -eq 0 ]; then
		utils.logResultOK "BLOTTER SERVER BAXTER CONFIGUATION SERVER STARTED SUCCESSFULLY\n"
		if [ -z $1 ]; then
	 		utils.listenConfirmation menus.baxter.showBaxterTasksMenu menus.baxter.listenBaxterTasksMenu
	 	fi
		return 0
 	else
		utils.logResultKO "BLOTTER SERVER BAXTER CONFIGUATION SERVER FAILED TO START\n"
		if [ -z $1 ]; then
	 		utils.listenConfirmation menus.baxter.showBaxterTasksMenu menus.baxter.listenBaxterTasksMenu
	 	fi
		return 1
	fi
}

# Stops Baxter Price Engine Broadcast
# Usage: baxterTasks.stopBaxterBroadcast $1
# $1: $TARGET_MACHINE
function baxterTasks.stopBaxterBroadcast(){
	# Stop Broadcast Server
	declare -x REMOTE_BAXTER_COMMAND="
		. .bash_profile;
		$BAXTER_HOME/bin/broadcast stop;
		exitcode=\$?;
		if [ \$exitcode = 0 ]; then
			echo 'Command SUCCESS';
		else
			echo 'Command FAILURE';
		fi;
		exit \$exitcode;"
		
	#$BAXTER_HOME/bin/broadcast stop
	baxterTasks.operateBaxter "$REMOTE_BAXTER_COMMAND" "$1"
	if [ $? -eq 0  ]; then
		utils.logResultOK "BROADCAST SERVER BAXTER CONFIGUATION SERVER STOPPED SUCCESSFULLY\n"
		if [ -z $1 ]; then
	 		utils.listenConfirmation menus.baxter.showBaxterTasksMenu menus.baxter.listenBaxterTasksMenu
	 	fi
		return 0
 	else
		utils.logResultKO "BROADCAST SERVER BAXTER CONFIGUATION SERVER FAILED TO STOP\n"
		if [ -z $1 ]; then
	 		utils.listenConfirmation menus.baxter.showBaxterTasksMenu menus.baxter.listenBaxterTasksMenu
	 	fi
		return 1
	fi
}

# Starts Baxter Price Engine Broadcast
# Usage: baxterTasks.startBaxterBroadcast $1
# $1: $TARGET_MACHINE
function baxterTasks.startBaxterBroadcast(){
	# Start Broadcast Server
	#/bin/bash -c '$BAXTER_HOME/bin/broadcast start'
	declare -x REMOTE_BAXTER_COMMAND="
		. .bash_profile;
		$BAXTER_HOME/bin/broadcast start;
		exitcode=\$?;
		if [ \$exitcode = 0 ]; then
			echo 'Command SUCCESS';
		else
			echo 'Command FAILURE';
		fi;
		exit \$exitcode;"
		
	#$BAXTER_HOME/bin/broadcast start
	baxterTasks.operateBaxter "$REMOTE_BAXTER_COMMAND" "$1"
	if [ $? -eq 0  ]; then
		utils.logResultOK "BROADCAST SERVER BAXTER CONFIGUATION SERVER STARTED SUCCESSFULLY\n"
		if [ -z $1 ]; then
	 		utils.listenConfirmation menus.baxter.showBaxterTasksMenu menus.baxter.listenBaxterTasksMenu
	 	fi
		return 0
 	else
		utils.logResultKO "BROADCAST SERVER BAXTER CONFIGUATION SERVER FAILED TO START\n"
		if [ -z $1 ]; then
	 		utils.listenConfirmation menus.baxter.showBaxterTasksMenu menus.baxter.listenBaxterTasksMenu
	 	fi
		return 1
	fi
}

# Starts Baxter Price Engine Dashboard Web Application
# Usage: baxterTasks.startBaxterDashboard $1
# $1: $TARGET_MACHINE
function baxterTasks.startBaxterDashboard(){
	# Start Dashboard Server
	#/bin/bash -c '$BAXTER_HOME/bin/dashboard start'
	declare -x REMOTE_BAXTER_COMMAND="
		. .bash_profile;
		$BAXTER_HOME/bin/dashboard start;
		exitcode=\$?;
		if [ \$exitcode = 0 ]; then
			echo 'Command SUCCESS';
		else
			echo 'Command FAILURE';
		fi;
		exit \$exitcode;"
		
	#$BAXTER_HOME/bin/dashboard start
	baxterTasks.operateBaxter "$REMOTE_BAXTER_COMMAND" "$1"
	if [ $? -eq 0  ]; then
		utils.logResultOK "DASHBOARD SERVER BAXTER CONFIGUATION SERVER STARTED SUCCESSFULLY\n"
		if [ -z $1 ]; then
	 		utils.listenConfirmation menus.baxter.showBaxterTasksMenu menus.baxter.listenBaxterTasksMenu
	 	fi
		return 0
 	else
		utils.logResultKO "DASHBOARD SERVER BAXTER CONFIGUATION SERVER FAILED TO START\n"
		if [ -z $1 ]; then
	 		utils.listenConfirmation menus.baxter.showBaxterTasksMenu menus.baxter.listenBaxterTasksMenu
	 	fi
		return 1
	fi
}

# Updates Baxter Price Engine DBServer Configuration
# Usage: baxterTasks.updateBaxterDBServer $1
# $1: $TARGET_MACHINE
function baxterTasks.updateBaxterDBServer(){
	# Update DB Server
	declare -x REMOTE_BAXTER_COMMAND="
		. .bash_profile;
		$BAXTER_HOME/bin/dbserver setup update;
		exitcode=\$?;
		if [ \$exitcode = 0 ]; then
			echo 'Command SUCCESS';
		else
			echo 'Command FAILURE';
		fi;
		exit \$exitcode;"
		
	#$BAXTER_HOME/bin/dbserver setup update
	baxterTasks.operateBaxter "$REMOTE_BAXTER_COMMAND" "$1"
	if [ $? -eq 0  ]; then
		utils.logResultOK "DB SERVER BAXTER UPDATED SUCCESSFULLY\n"
		if [ -z $1 ]; then
	 		utils.listenConfirmation menus.baxter.showBaxterTasksMenu menus.baxter.listenBaxterTasksMenu
	 	fi
		return 0
 	else
		utils.logResultKO "DB SERVER BAXTER FAILED TO UPDATE\n"
		if [ -z $1 ]; then
	 		utils.listenConfirmation menus.baxter.showBaxterTasksMenu menus.baxter.listenBaxterTasksMenu
	 	fi
		return 1
	fi
}

# Remove Baxter Logs
# Usage: baxterTasks.removeLogs $1
# $1: $TARGET_MACHINE
function baxterTasks.removeLogs(){
	# Update DB Server
	declare -x REMOTE_BAXTER_COMMAND="
		. .bash_profile;
		rm $BAXTER_HOME/log/*;
		exitcode=\$?;
		if [ \$exitcode = 0 ]; then
			echo 'Command SUCCESS';
		else
			echo 'Command FAILURE';	
		fi;
		exit \$exitcode;"
		
	baxterTasks.operateBaxter "$REMOTE_BAXTER_COMMAND" "$1"
	if [ $? -eq 0  ]; then
		utils.logResultOK "BAXTER LOGS REMOVED SUCCESSFULLY\n"
		if [ -z $1 ]; then
	 		utils.listenConfirmation menus.baxter.showBaxterTasksMenu menus.baxter.listenBaxterTasksMenu
	 	fi
		return 0
 	else
		utils.logResultKO "BAXTER LOGS FAILED TO REMOVE\n"
		if [ -z $1 ]; then
	 		utils.listenConfirmation menus.baxter.showBaxterTasksMenu menus.baxter.listenBaxterTasksMenu
	 	fi
		return 1
	fi
}

# Starts Baxter
# Usage: baxterTasks.startBaxter $1
# $1: $TARGET_MACHINE
function baxterTasks.startBaxter(){
	BAXTER_START_WAIT_TIME=15
	if [ -z $1 ]; then
		utils.getTargetBaxterConf
	fi
	# Start Configuration Server
	baxterTasks.startBaxterConfigurationServer "$TARGET_MACHINE"
	# Start DB Server
	if [ $? -eq 0 ]; then
		baxterTasks.startBaxterDBServer "$TARGET_MACHINE"
	fi
	# Start Blotter Server
	if [ $? -eq 0 ]; then
		#sleep $BAXTER_START_WAIT_TIME
		baxterTasks.startBaxterBlotterServer "$TARGET_MACHINE"
	fi
	# Start Broadcast Server
	if [ $? -eq 0 ]; then
		#sleep $BAXTER_START_WAIT_TIME
		baxterTasks.startBaxterBroadcast "$TARGET_MACHINE"
	fi
	# Start Dashboard Server
	if [ $? -eq 0 ]; then
		#sleep $BAXTER_START_WAIT_TIME
		baxterTasks.startBaxterDashboard "$TARGET_MACHINE"
	fi
	if [ $? -eq 0 ]; then
		utils.logFinalResultOK "BAXTER STARTED SUCCESSFULLY ###"
		if [ -z $1 ]; then
	 		utils.listenConfirmation menus.baxter.showBaxterTasksMenu menus.baxter.listenBaxterTasksMenu
	 	fi
	else 
		utils.logFinalResultKO "BAXTER FAILED TO START ###"
		if [ -z $1 ]; then
	 		utils.listenConfirmation menus.baxter.showBaxterTasksMenu menus.baxter.listenBaxterTasksMenu
	 	fi		
	fi
	#wait
}

# Restarts Baxter
# Usage: baxterTasks.restartBaxter
function baxterTasks.restartBaxter(){
	utils.getTargetBaxterConf
	 # Stop processes now
	 baxterTasks.stopBaxter "$TARGET_MACHINE"
	 # Clean old logs
	 if [ $? -eq 0 ]; then
	 	#[ "$(ls -A $BAXTER_HOME/log)" ]
	 	#sleep $BAXTER_START_WAIT_TIME
	 	baxterTasks.removeLogs "$TARGET_MACHINE"
	 fi	
	 # Start processes now
	 if [ $? -eq 0 ]; then
	 	baxterTasks.startBaxter "$TARGET_MACHINE"
	 fi
	 utils.listenConfirmation menus.baxter.showBaxterTasksMenu menus.baxter.listenBaxterTasksMenu
}

# Operates Baxter
# Usage: baxterTasks.operateBaxter $1 $2
# $1: operation command
# $2: $TARGET_MACHINE
function baxterTasks.operateBaxter(){
	if [ -z $2 ]; then
		utils.getTargetBaxterConf
	fi 
	# operate the process
	echo "Baxter on $TARGET_ENV runs on: $TARGET_MACHINE Machine on Port: $TARGET_PORT"
	#echo "$1"	
	ssh "$USER_BAXTER@$TARGET_MACHINE" "$1"
	#echo $?
	if [ $? = 0 ]; then
		return 0
	elif [ $? = 255 ]; then
		return 0 	
	else
		return 1
	fi
}