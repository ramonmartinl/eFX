################################################################################
#!/bin/env bash
#
# Script for uploading New Software Releases To RedHat Satellite Channels
#
# Usage: uploadSW2Satellite.sh $1
# $1: APPLICATION SW (Ej: Cerebro)
#
# Author: Ramon Martin Lopez [ramn.martn@servexternos.isban.es]
# Since: 19/01/2015 
# Last Modified: 27/01/2015 (ramn.martn)
#
###############################################################################

APPLICATION=$1
RELEASE_NUMBER=""

# UPLOAD SW TO SATELLITE CHANNELS
# Usage: uploadSW2Satellite.upload2Satellite $1
# $1: Application (optional)
# $2: Release Number (optional)
function uploadSW2Satellite.upload2Satellite() { 

	if [ -z $1 ] && [  -z $2 ]; then
		# Read Application name & Release Number from user input
		echo -n "Please introduce Application name, Options: Cerebro, Caplin, Baxter, etc.. > "
		read application
		APPLICATION="$application"
		echo -e "\nChoose a Release from one of the following in $UPLOAD_AREA_FOLDER	\n"
		#find $UPLOAD_AREA_FOLDER -type d | grep $APPLICATION
		echo -n "Please introduce Release number, Ej.: 3.4.29 > "
		read releaseNumber 
		RELEASE_NUMBER="$releaseNumber"
	else 	
		#APPLICATION=$(echo "$1" | tr '[:lower:]' '[:upper:]')
		APPLICATION="$1"
		RELEASE_NUMBER="$2"
	fi

	
	SW_RELEASE_FOLDER="$APPLICATION.$RELEASE_NUMBER"
	RELEASE_FOLDER="${UPLOAD_AREA_FOLDER}/${SW_RELEASE_FOLDER}"
	SATELLITE_USER="efxbuild"
	SATELLITE_PASSWD="RedHat01"
	SATELLITE_EFX_CHANNELS_TMP=SATELLITE_CHANNELS_EFX.out
	SATELLITE_CAPLIN_CHANNELS_TMP=SATELLITE_CHANNELS_CAPLIN.out

	#List EFX SATELLITE CHANNELS
	touch $SATELLITE_EFX_CHANNELS_TMP
	$EFX_INSTALLER_HOME/satelliteChannels.efx.sh > $SATELLITE_EFX_CHANNELS_TMP
	
	#List CAPLIN SATELLITE CHANNELS
	touch $SATELLITE_CAPLIN_CHANNELS_TMP
	$EFX_INSTALLER_HOME/satelliteChannels.caplin.sh > $SATELLITE_CAPLIN_CHANNELS_TMP
	
	# Check 4 existence of Release Folder in the FS
	if [ ! -d "$RELEASE_FOLDER" ]; then
	  echo "$(date): Sorry You must create Directory $RELEASE_FOLDER first" | tee --append $EFX_INSTALLER_ERROR_FILE
	  return 1
	fi
	
	# Choose correct Channels depending on Application
	if [ "$APPLICATION" = "Cerebro" ] || [ "$APPLICATION" = "Baxter" ] || [ "$APPLICATION" = "Baxter_Air" ]; then
		selectedSatelliteChannels=$SATELLITE_EFX_CHANNELS_TMP
	else # Caplin 
		selectedSatelliteChannels=$SATELLITE_CAPLIN_CHANNELS_TMP
	fi
	
	# Upload to every Channel
	utils.logResult "Uploading $SW_RELEASE_FOLDER to Satellite EFX Channels..."
	count=0	
	countFailed=0
	declare -x uploadResult=true
	while read CHANNEL
	do
		let count++
		utils.logResult "Uploading to Channel: $CHANNEL [$count]..."
		#Be careful when a biger release number already exists, you can´t use --newest property. 
		#The process can also fail if it detects the same artifact with a different md5sum 
		#rhnpush --channel=$CHANNEL -d $RELEASE_FOLDER --newest --server=https://lnx-satellitep1.ants.ad.anplc.co.uk/APP -u $SATELLITE_USER  -p $SATELLITE_PASSWD >>$EFX_INSTALLER_LOG_FILE
		rhnpush --channel=$CHANNEL -d $RELEASE_FOLDER --server=https://lnx-satellitep1.ants.ad.anplc.co.uk/APP -u $SATELLITE_USER  -p $SATELLITE_PASSWD >>$EFX_INSTALLER_LOG_FILE
		if [ $? = 0 ]; then
			utils.logResultOK "Upload $SW_RELEASE_FOLDER to Satellite EFX Channel $CHANNEL SUCCESS"
		else 
			utils.logResultKO "Upload $SW_RELEASE_FOLDER to Satellite EFX Channel $CHANNEL FAILED"
			uploadResult=false
			let countFailed++
		fi
		rhnpush -l --channel=$CHANNEL -d $RELEASE_FOLDER --server=https://lnx-satellitep1.ants.ad.anplc.co.uk/APP -u $SATELLITE_USER  -p $SATELLITE_PASSWD | grep $RELEASE_NUMBER >>$EFX_INSTALLER_LOG_FILE
	done < $selectedSatelliteChannels
	
	#remove temporary files
	#rm $SATELLITE_EFX_CHANNELS_TMP $SATELLITE_CAPLIN_CHANNELS_TMP
	if [ $uploadResult = true ]; then
		utils.logFinalResultOK "SUCCESSFULLY UPLOADED $APPLICATION.$RELEASE_NUMBER TO $count SATELLITE EFX CHANNELS"
	else
		utils.logFinalResultKO "$APPLICATION.$RELEASE_NUMBER FAILED TO UPLOAD TO $countFailed SATELLITE EFX CHANNELS"
	fi	
}

#declare -f