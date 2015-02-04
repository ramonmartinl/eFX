################################################################################
#!/bin/env bash
#
# Script for Executing other Maintenance Tasks
#
# Usage: maintenanceTasks.sh
#
# Author: Ramon Martin Lopez [ramn.martn@servexternos.isban.es]
# Since: 23/01/2015 
# Last Modified: 23/01/2015 (ramn.martn)
#
###############################################################################

# Añadir SSH
#Start LP Points Simulation in 'lnx-efxd38' host as 'strmbase' user
#http://www.linuxproblem.org/art_9.html
#http://www.octopuscs.com/blogs/Linux/How-to-avoid-entering-passwords-when-SSH-to-remote-machine

# Downloads software from URL
# Usage: downloadEFX
function downloadEFX(){
	#wget option URL
	echo "hola"
}

# Start LP Points Simulation
# Usage: startSimulationPoints
function startSimulationPoints(){
	#ssh -OPTIONS -p SSH_PORT user@remote_server "remote_command1; remote_command2; remote_script.sh" 
	ssh strmbase@lnx-efxd38 /dev/shm/d3data/startServer.sh.NDF
}

# Stops Baxter
# Usage: maintenanceTasks.stopBaxter
function maintenanceTasks.stopBaxter(){
	# Stop processes now
	 kill -9 `ps -fu baxter|grep java|grep -v grep|awk '{print $2}'`
	 #wait
	utils.logResult "BAXTER STOPPED SUCCESSFULLY ###"
}

# Starts Baxter
# Usage: maintenanceTasks.startBaxter
function maintenanceTasks.startBaxter(){
	# Start Configuration Server
	$BAXTER_HOME/bin/start-configuration-server --daemon &
	# Start DB Server
	if [[ $? == 0 ]]
	then
		utils.logResult "Configuration Server Baxter Process started succesfully\n"
		#/bin/bash -c '$BAXTER_HOME/bin/dbserver start'
		$BAXTER_HOME/bin/dbserver start
	else 
		utils.logResult "Configuration Server Baxter Process failed to start\n"
	fi
	# Start Blotter Server
	if [[ $? == 0 ]]
	then
		utils.logResult "DB Server Baxter Process started succesfully\n"
		#/bin/bash -c '$BAXTER_HOME/bin/blotterserver start'
		$BAXTER_HOME/bin/blotterserver start
	else 
		utils.logResult "DB Server Baxter Process failed to start\n"
	fi
	# Start Broadcast Server
	if [[ $? == 0 ]]
	then
		utils.logResult "Blotter Server Baxter Process started succesfully\n"
		#/bin/bash -c '$BAXTER_HOME/bin/broadcast start'
		$BAXTER_HOME/bin/broadcast start
	else 
		utils.logResult "Blotter Server Baxter Process failed to start\n"
	fi
	# Start Dashboard Server
	if [[ $? == 0 ]]
	then
		utils.logResult "Broadcast Server Baxter Process started succesfully\n"
		#/bin/bash -c '$BAXTER_HOME/bin/dashboard start'
		$BAXTER_HOME/bin/dashboard start
	else 
		utils.logResult "Broadcast Server Baxter Process failed to start\n"
	fi
	if [[ $? == 0 ]]
	then
		utils.logResult "Dashboard Server Baxter Process started succesfully\n"
		utils.logResult "BAXTER STARTED SUCCESSFULLY ###"
	else 
		utils.logResult "Dashboard Server Baxter Process failed to start\n"
		utils.logResult "BAXTER FAILED TO START ###"
	fi
	    #wait
}

# Restarts Baxter
# Usage: maintenanceTasks.restartBaxter
function maintenanceTasks.restartBaxter(){
	 # Stop processes now
	 maintenanceTasks.stopBaxter
	 # Start processes now
	 maintenanceTasks.startBaxter
}
