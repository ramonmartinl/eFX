################################################################################
#!/bin/env bash
#
# Script for listing EFX Satellite Channels
#
# Usage: efxChannels.sh
#
# Author: Eduardo Turiel Martinez [eduardo.turiel@servexternos.isban.es]
# Since: 19/01/2015 
# Last Modified: 20/01/2015 (ramn.martn)
#
###############################################################################
$EFX_INSTALLER_HOME/listChannels.sh 2>/dev/null | grep efx
