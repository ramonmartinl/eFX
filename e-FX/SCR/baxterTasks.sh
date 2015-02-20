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
# Usage: baxterTasks.stopBaxter
function baxterTasks.stopBaxter(){
	# Stop processes now
	 kill -9 `ps -fu baxter|grep java|grep -v grep|awk '{print $2}'`
	 #wait
	utils.logResult "BAXTER STOPPED SUCCESSFULLY ###"
}

# Starts Baxter Configuration Server
# Usage: baxterTasks.startBaxterConfigurationServer
function baxterTasks.startBaxterConfigurationServer(){
	# Start Configuration Server
	$BAXTER_HOME/bin/start-configuration-server --daemon &
	utils.logResult "Configuration Server Baxter Process started successfully\n"
	return 0
}

# Starts Baxter Price Engine DBServer
# Usage: baxterTasks.startBaxterDBServer
function baxterTasks.startBaxterDBServer(){
	# Start DB Server
	#/bin/bash -c '$BAXTER_HOME/bin/dbserver start'
	$BAXTER_HOME/bin/dbserver start
	utils.logResult "DB Server Baxter Process started successfully\n"
	return 0
}

# Starts Baxter Blotter Server
# Usage: baxterTasks.startBaxterBlotterServer
function baxterTasks.startBaxterBlotterServer(){
	# Start Blotter Server
	#/bin/bash -c '$BAXTER_HOME/bin/blotterserver start'
	$BAXTER_HOME/bin/blotterserver start
	utils.logResult "Blotter Server Baxter Process started successfully\n"
	return 0
}

# Starts Baxter Price Engine Broadcast
# Usage: baxterTasks.startBaxterBroadcast
function baxterTasks.startBaxterBroadcast(){
	# Start Broadcast Server
	#/bin/bash -c '$BAXTER_HOME/bin/broadcast start'
	$BAXTER_HOME/bin/broadcast start
	utils.logResult "Broadcast Server Baxter Process started succesfully\n"
	return 0
}

# Starts Baxter Price Engine Dashboard Web Application
# Usage: baxterTasks.startBaxterDashboard
function baxterTasks.startBaxterDashboard(){
	# Start Dashboard Server
	#/bin/bash -c '$BAXTER_HOME/bin/dashboard start'
	$BAXTER_HOME/bin/dashboard start
	utils.logResult "Dashboard Server Baxter Process started succesfully\n"
	return 0
}

# Updates Baxter Price Engine DBServer Configuration
# Usage: baxterTasks.updateBaxterDBServer
function baxterTasks.updateBaxterDBServer(){
	# Update DB Server
	$BAXTER_HOME/bin/dbserver setup update
	utils.logResult "DB Server Baxter Updated successfully\n"
	return 0
}

# Stops Baxter Price Engine Broadcast
# Usage: baxterTasks.stopBaxterBroadcast
function baxterTasks.stopBaxterBroadcast(){
	# Stop Broadcast Server
	$BAXTER_HOME/bin/broadcast stop
	utils.logResult "Broadcast Server Baxter Process stopped successfully\n"
	return 0
}

# Starts Baxter
# Usage: baxterTasks.startBaxter
function baxterTasks.startBaxter(){
	BAXTER_START_WAIT_TIME=15
	# Start Configuration Server
	baxterTasks.startBaxterConfigurationServer
	# Start DB Server
	if [[ $? == 0 ]]
	then
		sleep $BAXTER_START_WAIT_TIME
		baxterTasks.startBaxterDBServer
	else 
		utils.logResult "Configuration Server Baxter Process failed to start\n"
		#utils.logResult "DB Server Baxter failed to Update\n"
	fi
	# Start Blotter Server
	if [[ $? == 0 ]]
	then
		sleep $BAXTER_START_WAIT_TIME
		baxterTasks.startBaxterBlotterServer
	else 
		utils.logResult "DB Server Baxter Process failed to start\n"
	fi
	# Start Broadcast Server
	if [[ $? == 0 ]]
	then
		sleep $BAXTER_START_WAIT_TIME
		baxterTasks.startBaxterBroadcast
	else 
		utils.logResult "Blotter Server Baxter Process failed to start\n"
	fi
	# Start Dashboard Server
	if [[ $? == 0 ]]
	then
		sleep $BAXTER_START_WAIT_TIME
		baxterTasks.startBaxterDashboard
	else 
		utils.logResult "Broadcast Server Baxter Process failed to start\n"
	fi
	if [[ $? == 0 ]]
	then
		sleep $BAXTER_START_WAIT_TIME
		ps -fu baxter | tee --append $EFX_INSTALLER_LOG_FILE
		utils.logResult "BAXTER STARTED SUCCESSFULLY ###"
	else 
		utils.logResult "Dashboard Server Baxter Process failed to start\n"
		utils.logResult "BAXTER FAILED TO START ###"
	fi
	#wait
}

# Restarts Baxter
# Usage: baxterTasks.restartBaxter
function baxterTasks.restartBaxter(){
	 # Stop processes now
	 baxterTasks.stopBaxter
	 # Clean old logs
	 rm $BAXTER_HOME/log/*
	 if [ "$(ls -A $BAXTER_HOME/log)" ]; then
		utils.logResult "Baxter Logs are not removed correctly, $BAXTER_HOME/log is not empty\n"
	 else
		utils.logResult "Baxter Logs removed successfully\n"
	 fi
	 # Start processes now
	 baxterTasks.startBaxter
}
