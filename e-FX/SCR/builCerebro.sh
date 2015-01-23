################################################################################
#!/bin/env bash
#
# Script for building Cerebro RPM packages
#
# Usage: buildCerebro.sh
#
# Author: Ramon Martin Lopez [ramn.martn@servexternos.isban.es]
# Since: 19/01/2015 
# Last Modified: 22/01/2015 (ramn.martn)
#
###############################################################################

EFX_SCRIPTS_FOLDER=/home/efxbuild/eFX-Scripts
EFX_INSTALL_FOLDER=/home/efxbuild/eFX_install
RELEASE_NUMBER=""
JIRA_NUMBER=""
RELEASE_FOLDER=""

# Read new Release Details from Console
function ask4CerebroReleaseDetails() {
	echo -n "Please introduce new Release number, Ej.: 3.4.29 > "
	read releaseNumber
	RELEASE_NUMBER=$releaseNumber
	RELEASE_FOLDER=$EFX_SCRIPTS_FOLDER/$RELEASE_NUMBER
	echo -n "Please introduce JIRA number, Ej.: 19970 > "
	read jiraNumber
	JIRA_NUMBER=$jiraNumber
	echo -e "\n$(date): New Cerebro Release Properties introduced succesfully" | tee --append $EFX_INSTALLER_LOG_FILE
}

# EDIT release.properties FILE WITH PARAMETERS FOR THE NEW RELEASE
#installDir=/home/efxbuild/eFX-Scripts/3.4.30
#branchName=3.4
#devName=SIT1
#tagName=3.4.30
#previousTag=3.4.29
#commitMsg="[GBM-19970] Cerebro Release 3.4.30"
function editReleaseProperties() {
	sed -i '1s\.*\installDir='"$EFX_SCRIPTS_FOLDER"'/'"$RELEASE_NUMBER"'\' $EFX_SCRIPTS_FOLDER/release.properties
	sed -i '3s/.*/devName=SIT1/' $EFX_SCRIPTS_FOLDER/release.properties
	sed -i '4s/.*/tagName='"$RELEASE_NUMBER"'/' $EFX_SCRIPTS_FOLDER/release.properties
	sed -i '6s/.*/commitMsg="[GBM-'"$JIRA_NUMBER"'] Cerebro Release '"$RELEASE_NUMBER"'"/' $EFX_SCRIPTS_FOLDER/release.properties
	echo -e "\n$(date): release.propeties file changed succesfully" | tee --append $EFX_INSTALLER_LOG_FILE
}

# CREATE NEW RELEASE FOLDER
function createNewReleaseFolder() {
	if [ ! -d "$RELEASE_FOLDER" ]; then
		mkdir $RELEASE_FOLDER
	  	echo -e "\n$(date): Created nonExistent $RELEASE_FOLDER Folder succesfully" | tee --append $EFX_INSTALLER_LOG_FILE
	else echo -e "\n$(date): $RELEASE_FOLDER Folder already exists" | tee --append $EFX_INSTALLER_LOG_FILE
	fi

}

# BUILD APPLICATION CODE
function buildApplication() {
	echo -e "\n$(date): Building Cerebro.$RELEASE_NUMBER from $RELEASE_FOLDER Folder..." | tee --append $EFX_INSTALLER_LOG_FILE
	$EFX_SCRIPTS_FOLDER/release.sh | tee --append $EFX_INSTALLER_LOG_FILE
	echo -e "\n$(date): Cerebro.$RELEASE_NUMBER build succesfully" | tee --append $EFX_INSTALLER_LOG_FILE

}

# CLEAN . & .svn FILES FROM RELEASE FOLDER
function cleanNewReleaseFolder() {
	echo -e "\nCleaning . & .svn Files succesfully from $RELEASE_FOLDER..."
	find $RELEASE_FOLDER -name ".svn" | awk '{print "rm -rf "$0}' | sh
	find $RELEASE_FOLDER/SB7 -name "." | awk '{print "rm -rf "$0}' | sh
	find $RELEASE_FOLDER/Linux -name "." | awk '{print "rm -rf "$0}' | sh
	echo -e "\n$(date): . & .svn Files cleaned succesfully from $RELEASE_FOLDER" | tee --append $EFX_INSTALLER_LOG_FILE
}

# BUILD RPM PACKAGES with (efx001) Passwd
function buildRPMPackages() {
	showBuildEFXModulesMenu
	#$EFX_INSTALL_FOLDER/buildRPM_3.2_Final.sh $RELEASE_NUMBER 1 /local/home/strmbase $4 
}

# BUILD SHELL SCRIPTS with (efx001) Passwd
function buildShellScripts() {
	showBuildEFXModulesMenu
	$EFX_INSTALL_FOLDER/buildRPM_3.2_Linux.sh $RELEASE_NUMBER 1 /local/home/strmbase $4 
}