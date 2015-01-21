################################################################################
#!/bin/env bash
#
# Script for installing SCerebro Releases
#
# Usage: installSW.sh $1 $2
# $1: APPLICATION SW (Ej: CEREBRO)
# $2: SW RELEASE NUMBER (After /home/efxbuild/upload_area Ej.: x.y.z) #
#
# Author: Ramon Martin Lopez [ramn.martn@servexternos.isban.es]
# Since: 21/01/2015 
# Last Modified: 21/01/2015 (ramn.martn)
#
###############################################################################

EFX_SCRIPTS_FOLDER="/home/efxbuild/eFX-Scripts"
EFX_INSTALLER_FOLDER="/home/efxbuild/eFX_installer"
RELEASE_NUMBER="x.y.z"

# Read Release Number from user input
function ask4ReleaseNumber() {
	echo -n "Please introduce release number, Ej.: 3.4.29 > "
	read releaseNumber
	RELEASE_NUMBER=$releaseNumber
}

# CREATE NEW RELEASE FOLDER
function createNewReleaseFolder() {
	# Check 4 existence of Release Folder in the FS
	if [ ! -d "$EFX_SCRIPTS_FOLDER/$RELEASE_NUMBER" ]; then
	  echo "Creating Directory $EFX_SCRIPTS_FOLDER/$RELEASE_NUMBER.."
	  mkdir $EFX_SCRIPTS_FOLDER/$RELEASE_NUMBER
	fi
}

# EDIT release.properties FILE WITH PARAMETERS FOR THE NEW RELEASE
function editReleaseProperties() {
}

# BUILD APPLICATION CODE
function buildApplication() {
	# Buils Application Code by executing release.sh script
	$EFX_SCRIPTS_FOLDER/release.sh >>$EFX_INSTALLER_HOME/installSW.log
}

# CLEAN . & .svn FILES FROM RELEASE FOLDER
function cleanNewReleaseFolder() {
	find $EFX_SCRIPTS_FOLDER/$RELEASE_NUMBER -name ".svn" | awk '{print "rm -rf "$0}' | sh
	find $EFX_SCRIPTS_FOLDER/$RELEASE_NUMBER/SB7 -name "." | awk '{print "rm -rf "$0}' | sh
	find $EFX_SCRIPTS_FOLDER/$RELEASE_NUMBER/Linux -name "." | awk '{print "rm -rf "$0}' | sh
}

# BUILD RPM PACKAGES with passwd (efx001)
function buildRPMPackages() {
	./buildRPM_3.2_Final.sh $RELEASE_NUMBER $2 /local/home/strmbase $MODULE 
	./buildRPM_3.2_Linux.sh $RELEASE_NUMBER $2 /local/home/strmbase $MODULE
}