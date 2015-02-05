################################################################################
#!/bin/env bash
#
# Script for installing SW Releases
#
# Usage: installEFX.sh
#
# Author: Ramon Martin Lopez [ramn.martn@servexternos.isban.es]
# Since: 19/01/2015 
# Last Modified: 27/01/2015 (ramn.martn)
#
###############################################################################

declare -r EFX_INSTALLER_HOME=/home/efxbuild/UploadToSatellite
source $EFX_INSTALLER_HOME/installEFX.env

# allow read, write, and execute permission for all (potential security risk)
umask 000
# alias installEFX='/home/efxbuild/UploadToSatellite/installEFX.sh'

# Switch to 'strmbase' User
function switchUser_strmbase(){
	su - strmbase
}

# Switch to 'efxbuild' User
function switchUser_efxbuild(){
	su - efxbuild
}

# Switch to 'baxter' User
function switchUser_baxter(){
	su - baxter
}

# Clear installation log & error
touch $EFX_INSTALLER_LOG_FILE; >$EFX_INSTALLER_LOG_FILE
touch $EFX_INSTALLER_ERROR_FILE; >$EFX_INSTALLER_ERROR_FILE;

#declare -f
# Show Main Menu
showMainMenu
listenMainMenu
#declare -r
#declare -f
#return 0
#wait
#caller 0
