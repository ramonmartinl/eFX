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
# Last Modified: 20/01/2015 (ramn.martn)
#
###############################################################################

source  $EFX_INSTALLER_HOME/canal.sh

# Uploads a SW Release To Satellite Channels
function upload2Satellite { 

	UPLOAD_AREA="/home/efxbuild/upload_area/"
	#APPLICATION=$(echo "$1" | tr '[:lower:]' '[:upper:]')
	APPLICATION=$1
	SW_RELEASE_FOLDER=$APPLICATION.$2
	RELEASE_FOLDER=${UPLOAD_AREA}${SW_RELEASE_FOLDER}
	SATELLITE_USER="efxbuild"
	SATELLITE_PASSWD="RedHat01"
	SATELLITE_EFX_CHANNELS_TMP=SATELLITE_EFX_CHANNELS.out
	SATELLITE_CAPLIN_CHANNELS_TMP=SATELLITE_CAPLIN_CHANNELS.out

	#List EFX SATELLITE CHANNELS
	$EFX_INSTALLER_HOME/canalefx.sh > $SATELLITE_EFX_CHANNELS_TMP
	SATELLITE_EFX_CHANNELS[0]='clone-sgbm-efx-03-11-2014'
	SATELLITE_EFX_CHANNELS[1]='clone-sgbm-efx-01-01-2015'
	SATELLITE_EFX_CHANNELS[2]='clone-sgbm-efx-01-10-2014'
	SATELLITE_EFX_CHANNELS[3]='clone-sgbm-efx-01-12-2014'
	SATELLITE_EFX_CHANNELS[4]='clone-sgbm-efx-03-12-2014'
	SATELLITE_EFX_CHANNELS[5]='clone-sgbm-efx-rhel6-01-01-2015'
	SATELLITE_EFX_CHANNELS[6]='clone-sgbm-efx-rhel6-01-10-2014'
	SATELLITE_EFX_CHANNELS[7]='clone-sgbm-efx-rhel6-01-12-2014'
	SATELLITE_EFX_CHANNELS[8]='clone-sgbm-efx-rhel6-03-11-2014'
	SATELLITE_EFX_CHANNELS[9]='clone-sgbm-efx-rhel6-03-12-2014'
	SATELLITE_EFX_CHANNELS[10]='sgbm-efx'
	SATELLITE_EFX_CHANNELS[11]='sgbm-efx-rhel6'
	
	#List CAPLIN SATELLITE CHANNELS
	$EFX_INSTALLER_HOME/canalcaplin.sh > $SATELLITE_CAPLIN_CHANNELS_TMP
	
	# Check 4 Release Folder
	if [ ! -d "$RELEASE_FOLDER" ]; then
	  echo "Sorry You must create Directory $RELEASE_FOLDER first"
	  exit 0
	fi
	
	# Upload to every Channel
	count=0	
	while read CHANNEL
	do
		let count++
		echo "Uploading to Channel: $CHANNEL [$count] "
		rhnpush -l --channel=$CHANNEL -d $RELEASE_FOLDER --newest --server=https://lnx-satellitep1.ants.ad.anplc.co.uk/APP -u $SATELLITE_USER  -p $SATELLITE_PASSWD
	done < $SATELLITE_EFX_CHANNELS_TMP
	
	#remove temporary files
	rm $SATELLITE_EFX_CHANNELS_TMP $SATELLITE_CAPLIN_CHANNELS_TMP
	echo "Uploaded to $count Satellite EFX Channels as User: $SATELLITE_USER and Password: $SATELLITE_PASSWD from $RELEASE_FOLDER"
}

#Lists Active Satellite EFX Channels
function listSatelliteEFXChannels {
	listSatelliteChannels 2>/dev/null | grep efx
}

#Lists Active Satellite Caplin Channels
function listSatelliteCaplinChannels {
	listSatelliteChannels 2>/dev/null | grep caplin
}

#Lists Active Satellite Channels
function listSatelliteChannels {
	spacecmd -s lnx-satellitep1 -u efxbuild -p RedHat01 <<EOF
	softwarechannel_list
	EOF
}
