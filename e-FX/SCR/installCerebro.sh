################################################################################
#!/bin/env bash
#
# Script for installing new Cerebro Release
#
# Usage: installCerebro.sh
#
# Author: Ramon Martin Lopez [ramn.martn@servexternos.isban.es]
# Since: 03/02/2015 
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

# REMOVE INSTALLATION LINKS TO /local/home/strmbase
# Usage: removeInstallationLinks
function removeInstallationLinks(){
	unlink /local/home/strmbase/EFX-all
	unlink /local/home/strmbase/EFX-lp
}

# Builds a EFX Cerebro new Release
# Usage: builCerebro.builCerebro
function buildCerebro.builCerebro(){
	#caller 0
	ask4CerebroReleaseDetails 
	#editReleaseProperties
	editReleaseProperties_alt 
	#createNewReleaseFolder 
	#buildApplication
	wait 
	#cleanNewReleaseFolder 
	buildEFXRPMPackages 
	buildLinuxPMPackages 
	#uploadSW2Satellite.upload2Satellite Cerebro $RELEASE_NUMBER
}	

#declare -f