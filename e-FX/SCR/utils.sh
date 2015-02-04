################################################################################
#!/bin/env bash
#
# Script for utilities
#
# Usage: utils.sh
#
# Author: Ramon Martin Lopez [ramn.martn@servexternos.isban.es]
# Since: 27/01/2015 
# Last Modified: 27/01/2015 (ramn.martn)
#
###############################################################################

# sends a message to the log file
# Usage: utils.logResult $1
# $1: Message
function utils.logResult(){
	echo -e "\n### $(date): "$1" " | tee --append $EFX_INSTALLER_LOG_FILE
}

# Executes a command as user 4 Build
# Usage: utils.executeAsBuild $1
# $1: Command to execute
function utils.executeAsBuild(){
	if [ "$USER" != "$USER_EFXBUILD" ]; then
		#/opt/boksm/bin/suexec -u $USER_EFXBUILD source $EFX_INSTALLER_HOME/installEFX.env;$1
		su -m $USER_EFXBUILD -c 'source $EFX_INSTALLER_HOME/installEFX.env;$1'
	else
		$1
	fi
} 

# Executes a command as user 4 Baxter
# Usage: utils.executeAsBaxter $1
# $1: Command to execute
function utils.executeAsBaxter(){
	if [ "$USER" != "$USER_BAXTER" ]; then
		su -m $USER_BAXTER -c 'source $EFX_INSTALLER_HOME/installEFX.env;$1'
	else
		$1
	fi
} 


# Executes a command as user 4 Streambase
# Usage: utils.executeAsStreambase $1
# $1: Command to execute
function utils.executeAsStreambase(){
	if [ "$USER" != "$USER_STRMBASE" ]; then
		su -m $USER_STRMBASE -c 'source $EFX_INSTALLER_HOME/installEFX.env;$1'
	else
		$1
	fi
}