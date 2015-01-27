################################################################################
#!/bin/env bash
#
# Script for utilities
#
# Usage: utils.sh
#
# Author: Ramon Martin Lopez [ramn.martn@servexternos.isban.es]
# Since: 27/01/2015 
# Last Modified: 27/01/2015 (ramn.martn)
#
###############################################################################

# sends a message to the log file
# Usage: logResult $1
# $1: Message
function logResult(){
	echo -e "\n### $(date): "$1" " | tee --append $EFX_INSTALLER_LOG_FILE
}