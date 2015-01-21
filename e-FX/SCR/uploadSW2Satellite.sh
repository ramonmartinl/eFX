################################################################################
#!/bin/env bash
#
# Script for uploading New Software Releases To RedHat Satellite Channels
#
# Usage: uploadSW2Satellite.sh $1 $2
# $1: APPLICATION SW (Ej: CEREBRO)
# $2: SW RELEASE NUMBER (After /home/efxbuild/upload_area Ej.: x.y.z) #
#
# Author: Ramon Martin Lopez [ramn.martn@servexternos.isban.es]
# Since: 19/01/2015 
# Last Modified: 21/01/2015 (ramn.martn)
#
###############################################################################

# Uploads a SW Release To Satellite Channels
function upload2Satellite() { 

	UPLOAD_AREA_FOLDER="/home/efxbuild/upload_area/"

	# Read Release Number from user input
	echo -e "Choose a release from one of the following in $UPLOAD_AREA_FOLDER	\n"
	find /home/efxbuild/upload_area -type d | grep $1
	echo -n "Please introduce release number, Ej.: 3.4.29 > "
	read RELEASE_NUMBER
	
	#APPLICATION=$(echo "$1" | tr '[:lower:]' '[:upper:]')
	APPLICATION=$1
	SW_RELEASE_FOLDER=$APPLICATION.$RELEASE_NUMBER
	RELEASE_FOLDER=${UPLOAD_AREA_FOLDER}${SW_RELEASE_FOLDER}
	SATELLITE_USER="efxbuild"
	SATELLITE_PASSWD="RedHat01"
	SATELLITE_EFX_CHANNELS_TMP=SATELLITE_EFX_CHANNELS.out
	SATELLITE_CAPLIN_CHANNELS_TMP=SATELLITE_CAPLIN_CHANNELS.out

	#List EFX SATELLITE CHANNELS
	$EFX_INSTALLER_HOME/efxChannels.sh > $SATELLITE_EFX_CHANNELS_TMP
	
	#List CAPLIN SATELLITE CHANNELS
	$EFX_INSTALLER_HOME/caplinChannels.sh > $SATELLITE_CAPLIN_CHANNELS_TMP
	
	# Check 4 existence of Release Folder in the FS
	if [ ! -d "$RELEASE_FOLDER" ]; then
	  echo "Sorry You must create Directory $RELEASE_FOLDER first" | tee --append $EFX_INSTALLER_ERROR_FILE
	  exit 1
	fi
	
	# Choose correct Channels depending on Application
	if [ "$1" = "Cerebro" ] || [ "$1" = "Baxter" ] || [ "$1" = "Baxter_Air" ]; then
		selectedSatelliteChannels=$SATELLITE_EFX_CHANNELS_TMP
	else # Caplin 
		selectedSatelliteChannels=$SATELLITE_CAPLIN_CHANNELS_TMP
	fi
	
	# Upload to every Channel
	echo "Uploading $SW_RELEASE_FOLDER to Satellite EFX Channels as User: $SATELLITE_USER and Password: $SATELLITE_PASSWD..." | tee --append $EFX_INSTALLER_LOG_FILE
	count=0	
	while read CHANNEL
	do
		let count++
		echo -e "\nUploading to Channel: $CHANNEL [$count]..." | tee --append $EFX_INSTALLER_LOG_FILE
		rhnpush --channel=$CHANNEL -d $RELEASE_FOLDER --newest --server=https://lnx-satellitep1.ants.ad.anplc.co.uk/APP -u $SATELLITE_USER  -p $SATELLITE_PASSWD >>$EFX_INSTALLER_LOG_FILE
		rhnpush -l --channel=$CHANNEL -d $RELEASE_FOLDER --server=https://lnx-satellitep1.ants.ad.anplc.co.uk/APP -u $SATELLITE_USER  -p $SATELLITE_PASSWD | grep $RELEASE_NUMBER >>$EFX_INSTALLER_LOG_FILE
	done < $selectedSatelliteChannels
	
	#remove temporary files
	rm $SATELLITE_EFX_CHANNELS_TMP $SATELLITE_CAPLIN_CHANNELS_TMP
	
	echo -e "\n#########################################################################################"
	echo -e "### Uploaded $1 $RELEASE_NUMBER to $count Satellite EFX Channels as User: $SATELLITE_USER and Password: $SATELLITE_PASSWD" | tee --append $EFX_INSTALLER_LOG_FILE
	echo -e "#########################################################################################"
}
