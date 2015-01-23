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

# Start LP Points Simulation in 'lnx-efxd38' host as 'strmbase' user
# http://www.linuxproblem.org/art_9.html
# http://www.octopuscs.com/blogs/Linux/How-to-avoid-entering-passwords-when-SSH-to-remote-machine

# Downloads software from URL
function downloadSW(){
	#wget  [option]  [URL]
}

# Start LP Points Simulation
function startSimulationPoints(){
	#ssh -OPTIONS -p SSH_PORT user@remote_server "remote_command1; remote_command2; remote_script.sh" 
	ssh strmbase@lnx-efxd38 /dev/shm/d3data/startServer.sh.NDF
}