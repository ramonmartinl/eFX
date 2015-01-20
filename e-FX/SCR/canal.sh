################################################################################
#!/bin/env bash
#
# Script for listing Satellite Channels
#
# Usage: canal.sh
#
# Author: Eduardo Turiel Martinez [eduardo.turiel@servexternos.isban.es]
# Since: 19/01/2015 
# Last Modified: 20/01/2015 (ramn.martn)
#
###############################################################################

spacecmd -s lnx-satellitep1 -u efxbuild -p RedHat01 <<EOF
softwarechannel_list
EOF
