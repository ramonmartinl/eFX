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

#EFX_INSTALLER_HOME=/home/efxbuild/UploadToSatellite
EFX_INSTALLER_HOME=/home/jmonu5/InstallEFX

export $EFX_INSTALLER_HOME
source  $EFX_INSTALLER_HOME/uploadSW2Satellite.sh

#wget  [option]  [URL]

upload2Satellite $1 $2

