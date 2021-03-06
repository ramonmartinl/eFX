################################################################################
#!/bin/env bash
#
# Script for building Cerebro RPM packages
#
# Usage: buildCerebro.sh
#
# Author: Ramon Martin Lopez [ramn.martn@servexternos.isban.es]
# Since: 19/01/2015 
# Last Modified: 03/02/2015 (ramn.martn)
#
###############################################################################

declare -r EFX_SCRIPTS_FOLDER=/home/efxbuild/eFX-Scripts
declare -r EFX_INSTALLER_FOLDER=/home/efxbuild/eFX_installer
RELEASE_NUMBER=""
BRANCH_NAME=""
SIT_ENVIRONMENT=""
TAG_NAME=""
PREVIOUS_TAG=""
JIRA_NUMBER=""

RELEASE_FOLDER=""
FIXED_VERSION=false

export EFX_INSTALLER_FOLDER

# Read new Cerebro Release Details from Console
function ask4CerebroReleaseDetails() {
	# Introduce Release Number
	echo -n "Please introduce new Release number, Ej.: 3.4.29 > "
	read releaseNumber
	RELEASE_NUMBER=$releaseNumber
	RELEASE_FOLDER=$EFX_SCRIPTS_FOLDER/$RELEASE_NUMBER
	# Introduce Brach name
	echo -n "Please introduce Branch name, Ej.: 3.4 > "
	read branchName
	BRANCH_NAME=$branchName
	# Introduce SIT environment
	echo -n "Please introduce Environment, Ej.: SIT1 > "
	read devName
	SIT_ENVIRONMENT=$devName
	# Introduce Tag Name
	echo -n "Please introduce Tag name, Ej.: 3.4.29 > "
	read tagName
	TAG_NAME=$tagName
	# Introduce Previous Tag 
	echo -n "Please introduce previous Tag, Ej.: 3.4.28 > "
	read previousTag
	PREVIOUS_TAG=$previousTag
	# Introduce JIRA Number
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
	        	option_picked "\nyou chose to increase Version of generated artifacts"
	        	#sleep 1
	        	FIXED_VERSION=false
	        	break
	        	;;
	        
	        n) 
	        # Fixed Version
	            option_picked "\nyou chose not to increase Version of generated artifacts"
	            #sleep 1
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
	utils.logResult "New Cerebro Release Properties introduced succesfully"
}

# EDIT release.properties FILE WITH PARAMETERS FOR THE NEW RELEASE
#installDir=/home/efxbuild/eFX-Scripts/3.4.30
#branchName=3.4
#devName=SIT1
#tagName=3.4.30
#previousTag=3.4.29
#commitMsg="[GBM-19970] Cerebro Release 3.4.30"
#fixedVersion=3.4.33
function editReleaseProperties_alt() {
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
	utils.logResult "release.propeties file changed successfully"
}
# Alternative
function editReleaseProperties() {
	echo "installDir=$EFX_SCRIPTS_FOLDER/$RELEASE_NUMBER" >$EFX_SCRIPTS_FOLDER/release.properties
	echo "branchName=$BRANCH_NAME" >>$EFX_SCRIPTS_FOLDER/release.properties
	echo "devName=$SIT_ENVIRONMENT" >>$EFX_SCRIPTS_FOLDER/release.properties	
	echo "tagName=$TAG_NAME" >>$EFX_SCRIPTS_FOLDER/release.properties	
	echo "previousTag=$PREVIOUS_TAG" >>$EFX_SCRIPTS_FOLDER/release.properties
	echo "commitMsg=\"[GBM-$JIRA_NUMBER] Cerebro Release $RELEASE_NUMBER\"" >>$EFX_SCRIPTS_FOLDER/release.properties
	if [ "$FIXED_VERSION" = true ]; then
		echo "fixedVersion=$RELEASE_NUMBER" >>$EFX_SCRIPTS_FOLDER/release.properties
	fi
	utils.logResult "release.propeties file changed successfully"
}

# BUILD APPLICATION CODE
function buildApplication() {
	utils.logResult "Building Cerebro.$RELEASE_NUMBER from $RELEASE_FOLDER Folder..."
	$EFX_SCRIPTS_FOLDER/release.sh | tee --append $EFX_INSTALLER_LOG_FILE
	utils.logResult "Cerebro.$RELEASE_NUMBER build successfully"

}

# CLEAN . & .svn FILES FROM RELEASE FOLDER
function cleanNewReleaseFolder() {
	echo -e "\nCleaning . & .svn Files from $RELEASE_FOLDER..."
	find $RELEASE_FOLDER -name ".svn" | awk '{print "rm -rf "$0}' | sh
	find $RELEASE_FOLDER -name "src" | awk '{print "rm -rf "$0}' | sh
	find $RELEASE_FOLDER -name "target" | awk '{print "rm -rf "$0}' | sh
	find $RELEASE_FOLDER/SB7 -name "." | awk '{print "rm -rf "$0}' | sh
	find $RELEASE_FOLDER/Linux -name "." | awk '{print "rm -rf "$0}' | sh
	utils.logResult "Files cleaned successfully from $RELEASE_FOLDER"
}

# BUILD RPM PACKAGES with (efx001) Passwd
function buildEFXRPMPackages() {
	# Clear temporal file 4 specifying modules to build
	touch $NEW_EFX_MODULES_TMP.$RELEASE_NUMBER.out; >$NEW_EFX_MODULES_TMP.$RELEASE_NUMBER.out
	# show Menu 4 building modules
	showBuildEFXModulesMenu
	listenBuildEFXModulesMenu
}

# BUILD RPM PACKAGES with (efx001) Passwd
function buildEFXTrailPackages() {
	# Build EFX-Trial-all
	builCerebro.buildEFXTrialModule all
	# Build EFX-Trial-lp
	builCerebro.buildEFXTrialModule lp
}

# BUILD SHELL SCRIPTS with (efx001) Passwd
function buildLinuxRPMPackages() {
	# Clear temporal file 4 specifying modules to build
	touch $NEW_LINUX_MODULES_TMP.$RELEASE_NUMBER.out; >$NEW_LINUX_MODULES_TMP.$RELEASE_NUMBER.out
	# show Menu 4 building modules
	showBuildLinuxModulesMenu
	listenBuildLinuxModulesMenu
}

# Build RPM package for an EFX Module
# Usage: buildEFXModuleRPM $1
# $1: Module
function buildEFXModuleRPM(){
	$EFX_INSTALLER_HOME/rpmbuildEFX.exp $RELEASE_NUMBER 1 $1  | tee --append $EFX_INSTALLER_LOG_FILE
}

# Build a RPM package for all EFX Modules
# Usage: buildAllEFXModulesRPM
function buildAllEFXModulesRPM(){
	$EFX_INSTALLER_HOME/rpmbuildEFXAll.exp $RELEASE_NUMBER 1 all  | tee --append $EFX_INSTALLER_LOG_FILE
}

# Build RPM package for Module eFX-SB7-Common 
# Usage: buildEFXSB7CommonModulesRPM
function buildEFXSB7CommonModulesRPM(){
	$EFX_INSTALLER_HOME/rpmbuildEFXSB7Common.exp $RELEASE_NUMBER 1 eFX-SB7-Common  | tee --append $EFX_INSTALLER_LOG_FILE
}

# Build RPM package for an EFX-Trial Module
# Usage: buildEFXTrialModuleRPM $1
# $1: Module (all |lp)
function buildEFXTrialModuleRPM(){
	$EFX_INSTALLER_HOME/rpmbuildEFXTrial.exp $RELEASE_NUMBER 1 $1  | tee --append $EFX_INSTALLER_LOG_FILE
}

# Build a RPM package for a Linux Module
# Usage: buildLinuxModuleRPM $1
# $1: Module
function buildLinuxModuleRPM(){
	$EFX_INSTALLER_HOME/rpmbuildLinux.exp $RELEASE_NUMBER 1 $1  | tee --append $EFX_INSTALLER_LOG_FILE
}

# Build a RPM package for all Linux Modules
# Usage: buildAllLinuxModulesRPM
function buildAllLinuxModulesRPM(){
	$EFX_INSTALLER_HOME/rpmbuildLinuxAll.exp $RELEASE_NUMBER 1 all  | tee --append $EFX_INSTALLER_LOG_FILE
}

# Builds a EFX Module
# Usage: builCerebro.buildEFXModule $1
# $1: Module
function builCerebro.buildEFXModule(){
	utils.logResult "Building $1 Module for Cerebro.$RELEASE_NUMBER..."
	pushd $EFX_INSTALLER_FOLDER
	buildEFXModuleRPM $1
	logBuildModuleResult $1
	popd
}

# Builds all EFX Modules
# Usage: builCerebro.buildAllEFXModules
function builCerebro.buildAllEFXModules(){
	utils.logResult "Building all EFX Modules for Cerebro.$RELEASE_NUMBER..."
	pushd $EFX_INSTALLER_FOLDER
	buildAllEFXModulesRPM
	logBuildModuleResult all
	popd
}

# Builds EFX SB7-Common Modules
# Usage: builCerebro.buildEFXSB7CommonModules
function builCerebro.buildEFXSB7CommonModules(){
	utils.logResult "Building EFX-SB7-Common Modules for Cerebro.$RELEASE_NUMBER..."
	pushd $EFX_INSTALLER_FOLDER
	buildEFXSB7CommonModulesRPM
	logBuildModuleResult EFX-SB7-Common
	popd
}

# Builds a EFX-Trial Module
# Usage: builCerebro.buildEFXTrialModule $1
# $1: Module
function builCerebro.buildEFXTrialModule(){
	utils.logResult "Building EFX-Trial-$1 Module for Cerebro.$RELEASE_NUMBER..."
	pushd $EFX_INSTALLER_FOLDER
	buildEFXTrialModuleRPM $1
	logBuildModuleResult $1
	popd
}

# Builds a Linux Module
# Usage: builCerebro.buildLinuxModule $1
# $1: Module
function builCerebro.buildLinuxModule(){
	utils.logResult "Building $1 Module for Cerebro.$RELEASE_NUMBER..."
	pushd $EFX_INSTALLER_FOLDER
	buildLinuxModuleRPM $1
	logBuildModuleResult $1
	popd
}

# Builds all Linux Modules
# Usage: builCerebro.buildAllLinuxModules
function builCerebro.buildAllLinuxModules(){
	utils.logResult "Building all Linux Modules for Cerebro.$RELEASE_NUMBER..."
	pushd $EFX_INSTALLER_FOLDER
	buildAllLinuxModulesRPM
	logBuildModuleResult all
	popd
}

# Builds a EFX Cerebro new Release
# Usage: builCerebro.build
function buildCerebro.build(){
	#caller 0
	# Ask 4 user input to edit release properties
	ask4CerebroReleaseDetails 
	# EDIT 'release.properties' FILE WITH PARAMETERS FOR THE NEW RELEASE
	#editReleaseProperties
	# CREATE NEW RELEASE FOLDER
	#utils.createNewFolder "$RELEASE_FOLDER"
	# BUILD APPLICATION CODE AND CREATE NEW VERSION BRANCH
	#buildApplication
	#wait 
	# CLEAN . $ .svn FILES FROM NEW RELEASE FOLDER
	#cleanNewReleaseFolder 
	# BUILD EACH AFFECTED EFX MODULE RPM PACKAGE 
	buildEFXRPMPackages 
	# BUILD EACH AFFECTED LINUX MODULE RPM PACKAGE 
	#buildLinuxPMPackages 
	# BUILD EFX TRAIL RPM PACKAGES
	#buildEFXTrailPackages
	# UPLOAD RMP PACKAGES TO SATELLITE
	#uploadSW2Satellite.upload2Satellite Cerebro $RELEASE_NUMBER
}	

# sends the result of the execution of the last command to log file
# Usage: logBuildModuleResult $1
# $1: Module
function logBuildModuleResult(){
	if [[ $? == 0 ]]
	then
		utils.logResult "$1 Module for Cerebro.$RELEASE_NUMBER build succesfully"
	else 
		utils.logResult "$1 Module for Cerebro.$RELEASE_NUMBER failed to build"
	fi	
}

#declare -f