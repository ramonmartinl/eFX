################################################################################
#!/bin/env bash
#
# Script for building Cerebro RPM packages
#
# Usage: buildCerebro.sh
#
# Author: Ramon Martin Lopez [ramn.martn@servexternos.isban.es]
# Since: 19/01/2015 
# Last Modified: 27/01/2015 (ramn.martn)
#
###############################################################################

declare -r EFX_SCRIPTS_FOLDER=/home/efxbuild/eFX-Scripts
declare -r EFX_INSTALLER_FOLDER=/home/efxbuild/eFX_installer
RELEASE_NUMBER=""
JIRA_NUMBER=""
RELEASE_FOLDER=""
FIXED_VERSION=false

export EFX_INSTALLER_FOLDER

# Read new Release Details from Console
function ask4CerebroReleaseDetails() {
	echo -n "Please introduce new Release number, Ej.: 3.4.29 > "
	read releaseNumber
	RELEASE_NUMBER=$releaseNumber
	RELEASE_FOLDER=$EFX_SCRIPTS_FOLDER/$RELEASE_NUMBER
	echo -n "Please introduce JIRA number, Ej.: 19970 > "
	read jiraNumber
	JIRA_NUMBER=$jiraNumber
	echo -n "Do you want to increase Version of generated artifacts? Yes[y], No[n] > "
	read -n1 opt_fixedVersion
	while [ opt_fixedVersion != '' ]
	    do
	        case $opt_fixedVersion in
	        y) 
	        # No Fixed Version
	        	option_picked "you chose to increase Version of generated artifacts"
	        	FIXED_VERSION=false
	        	break
	        	;;
	        
	        n) 
	        # Fixed Version
	            option_picked "you chose not to increase Version of generated artifacts"
	            FIXED_VERSION=true
	            break
	            ;;
	
	        *) 
	        	#echo -n ""
	        	option_picked "\nSorry, you must enter a valid option: Yes[y], No[n] > ";
	        	read -n1 opt_fixedVersion
	        	;;
	    	esac
	done
	logResult "New Cerebro Release Properties introduced succesfully"
}

# EDIT release.properties FILE WITH PARAMETERS FOR THE NEW RELEASE
#installDir=/home/efxbuild/eFX-Scripts/3.4.30
#branchName=3.4
#devName=SIT1
#tagName=3.4.30
#previousTag=3.4.29
#commitMsg="[GBM-19970] Cerebro Release 3.4.30"
#fixedVersion=3.4.33
function editReleaseProperties() {
	sed -i 's\^installDir.*$\installDir='"$EFX_SCRIPTS_FOLDER"'/'"$RELEASE_NUMBER"'\' $EFX_SCRIPTS_FOLDER/release.properties
	sed -i 's/^devName.*$/devName=SIT1/' $EFX_SCRIPTS_FOLDER/release.properties
	sed -i 's/^tagName.*$/tagName='"$RELEASE_NUMBER"'/' $EFX_SCRIPTS_FOLDER/release.properties
	sed -i 's/^commitMsg.*$/commitMsg="[GBM-'"$JIRA_NUMBER"'] Cerebro Release '"$RELEASE_NUMBER"'"/' $EFX_SCRIPTS_FOLDER/release.properties
	if [ "$FIXED_VERSION" = false ]; then
		#sed '7d' $EFX_SCRIPTS_FOLDER/release.properties
		sed -i 's/^fixedVersion.*$/fixedVersion=/' $EFX_SCRIPTS_FOLDER/release.properties
	else		
		sed -i 's/^fixedVersion.*$/fixedVersion='"$RELEASE_NUMBER"'/' $EFX_SCRIPTS_FOLDER/release.properties
	fi	
	logResult "release.propeties file changed successfully"
}

# CREATE NEW RELEASE FOLDER
function createNewReleaseFolder() {
	if [ ! -d "$RELEASE_FOLDER" ]; then
		mkdir $RELEASE_FOLDER
		logResult "Created nonExistent $RELEASE_FOLDER Folder succesfully"
	else logResult "$RELEASE_FOLDER Folder already exists"
	fi

}

# BUILD APPLICATION CODE
function buildApplication() {
	logResult "Building Cerebro.$RELEASE_NUMBER from $RELEASE_FOLDER Folder..."
	$EFX_SCRIPTS_FOLDER/release.sh | tee --append $EFX_INSTALLER_LOG_FILE
	logResult "Cerebro.$RELEASE_NUMBER build successfully"

}

# CLEAN . & .svn FILES FROM RELEASE FOLDER
function cleanNewReleaseFolder() {
	echo -e "\nCleaning . & .svn Files from $RELEASE_FOLDER..."
	find $RELEASE_FOLDER -name ".svn" | awk '{print "rm -rf "$0}' | sh
	find $RELEASE_FOLDER/SB7 -name "." | awk '{print "rm -rf "$0}' | sh
	find $RELEASE_FOLDER/Linux -name "." | awk '{print "rm -rf "$0}' | sh
	logResult ". & .svn Files cleaned successfully from $RELEASE_FOLDER"
}

# BUILD RPM PACKAGES with (efx001) Passwd
function buildEFXRPMPackages() {
	showBuildEFXModulesMenu
	listenBuildEFXModulesMenu
}

# BUILD SHELL SCRIPTS with (efx001) Passwd
function buildLinuxPMPackages() {
	showBuildEFXModulesMenu
	$EFX_INSTALLER_FOLDER/buildRPM_3.2_Linux.sh $RELEASE_NUMBER 1 /local/home/strmbase $4 
}

# sends the result of the execution of the last command to log file
# Usage: logBuildModuleResult $1
# $1: Module
function logBuildModuleResult(){
	if [[ $? = 0 ]]
	then
		logResult "$1 Module for Cerebro.$RELEASE_NUMBER build succesfully"
	else 
		logResult "$1 Module for Cerebro.$RELEASE_NUMBER failed to build"
	fi	
}

# Build a RPM package for a Module
# Usage: buildModuleRPM $1
# $1: Module
function buildModuleRPM(){
	$EFX_INSTALLER_HOME/rpmbuild.exp $RELEASE_NUMBER 1 $1  | tee --append $EFX_INSTALLER_LOG_FILE
}

# Build a RPM package for all Modules
# Usage: buildAllModulesRPM
function buildAllModulesRPM(){
	$EFX_INSTALLER_HOME/rpmbuildAll.exp $RELEASE_NUMBER 1 all  | tee --append $EFX_INSTALLER_LOG_FILE
}

# Build RPM package for Module eFX-SB7-Common 
# Usage: buildEFXSB7CommonModulesRPM
function buildEFXSB7CommonModulesRPM(){
	$EFX_INSTALLER_HOME/rpmbuildSB7Common.exp $RELEASE_NUMBER 1 eFX-SB7-Common  | tee --append $EFX_INSTALLER_LOG_FILE
}

# Builds a EFX Module
# Usage: builCerebro.buildEFXModule $1
# $1: Module
function builCerebro.buildEFXModule(){
	logResult "Building $1 Module for Cerebro.$RELEASE_NUMBER..."
	pushd $EFX_INSTALLER_FOLDER
	buildModuleRPM $1
	logBuildModuleResult $1
	popd
}

# Builds all EFX Modules
# Usage: builCerebro.buildAllEFXModules
function builCerebro.buildAllEFXModules(){
	logResult "Building all EFX Modules for Cerebro.$RELEASE_NUMBER..."
	pushd $EFX_INSTALLER_FOLDER
	buildAllModulesRPM
	logBuildModuleResult all
	popd
}

# Builds EFX SB7-Common Modules
# Usage: builCerebro.buildEFXSB7CommonModules
function builCerebro.buildEFXSB7CommonModules(){
	logResult "Building EFX-SB7-Common Modules for Cerebro.$RELEASE_NUMBER..."
	pushd $EFX_INSTALLER_FOLDER
	buildEFXSB7CommonModulesRPM
	logBuildModuleResult EFX-SB7-Common
	popd
}

# Builds a EFX Cerebro new Release
# Usage: builCerebro.builCerebro
function buildCerebro.builCerebro(){
	#caller 0
	ask4CerebroReleaseDetails 
	editReleaseProperties 
	#createNewReleaseFolder 
	#buildApplication
	wait 
	#cleanNewReleaseFolder 
	buildEFXRPMPackages 
	#buildLinuxPMPackages 
	#uploadSW2Satellite.upload2Satellite Cerebro $RELEASE_NUMBER
}	

#declare -f