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

EFX_INSTALLER_HOME=/home/efxbuild/UploadToSatellite
EFX_INSTALLER_LOG_FILE=$EFX_INSTALLER_HOME/installSW.log
EFX_INSTALLER_ERROR_FILE=$EFX_INSTALLER_HOME/installSW.error

export EFX_INSTALLER_HOME
export EFX_INSTALLER_LOG_FILE
export EFX_INSTALLER_ERROR_FILE

source $EFX_INSTALLER_HOME/menus.sh
source $EFX_INSTALLER_HOME/builCerebro.sh
source $EFX_INSTALLER_HOME/uploadSW2Satellite.sh
source $EFX_INSTALLER_HOME/installCaplin.sh
source $EFX_INSTALLER_HOME/maintenanceTasks.sh
source $EFX_INSTALLER_HOME/utils.sh

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
rm $EFX_INSTALLER_LOG_FILE
rm $EFX_INSTALLER_ERROR_FILE

# Show Main Menu
showMainMenu
listenMainMenu
