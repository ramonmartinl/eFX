################################################################################
#!/bin/env bash
#
# Script for installing SW Releases
#
# Usage: installSW.sh $1 $2
# $1: APPLICATION SW (Ej: CEREBRO)
# $2: SW RELEASE NUMBER (After /home/efxbuild/upload_area Ej.: x.y.z) #
#
# Author: Ramon Martin Lopez [ramn.martn@servexternos.isban.es]
# Since: 19/01/2015 
# Last Modified: 20/01/2015 (ramn.martn)
#
###############################################################################

EFX_INSTALLER_HOME=/home/efxbuild/UploadToSatellite

export $EFX_INSTALLER_HOME
source  $EFX_INSTALLER_HOME/uploadSW2Satellite.sh

function showMenu {
	echo -e "#####################################"
	echo "# Welcome to the EFX Installation Program"
	echo -e "#####################################"
	PS3='Please enter your choice: '
	options=("Install Baxter" "Install Cerebro" "Install Caplin" "Quit")
	select opt in "${options[@]}"
	do
	    case $opt in
	        "Install Baxter")
	            echo "you chose to Install new Baxter release"
	            ;;
	        "Install Cerebro")
	            echo "you chose to Install new Cerebro release"
				upload2Satellite $1 $2
	            ;;
	        "Install Caplin")
	            echo "you chose to Install new Caplin release"
	            ;;
	        "Quit")
	            break
	            ;;
	        *) echo invalid option;;
	    esac
	done
}

#wget  [option]  [URL]

clear
showMenu


