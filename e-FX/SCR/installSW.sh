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
# Last Modified: 21/01/2015 (ramn.martn)
#
###############################################################################

EFX_INSTALLER_HOME=/home/efxbuild/UploadToSatellite
EFX_INSTALLER_LOG_FILE=$EFX_INSTALLER_HOME/installSW.log
EFX_INSTALLER_ERROR_FILE=$EFX_INSTALLER_HOME/installSW.error

export $EFX_INSTALLER_HOME
export $EFX_INSTALLER_LOG_FILE
export $EFX_INSTALLER_ERROR_FILE
source $EFX_INSTALLER_HOME/uploadSW2Satellite.sh

#Main menu
showMenu(){
    NORMAL=`echo "\033[m"`
    MENU=`echo "\033[36m"` #Blue
    NUMBER=`echo "\033[33m"` #yellow
    FGRED=`echo "\033[41m"`
    RED_TEXT=`echo "\033[31m"`
    ENTER_LINE=`echo "\033[33m"`
    clear
    echo -e "${MENU}#############################################${NORMAL}"
    echo -e "${MENU}# Welcome to the EFX Installation Program${NORMAL}"
    echo -e "${MENU}#############################################${NORMAL}"
    echo -e "${MENU}**${NUMBER} 1)${MENU} Install Baxter ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 2)${MENU} Install Baxter Air ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 3)${MENU} Install Cerebro ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 4)${MENU} Install Caplin ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 5)${MENU} ${NORMAL}"
    echo -e "${MENU}*********************************************${NORMAL}"
    echo -e "${ENTER_LINE}Please enter a menu option and enter or ${RED_TEXT}enter to exit. ${NORMAL}"
    read opt
}

#Show option picked
function option_picked() {
    COLOR='\033[01;31m' # bold red
    RESET='\033[00;00m' # normal white
    MESSAGE=${@:-"${RESET}Error: No message passed"}
    echo -e "${COLOR}${MESSAGE}${RESET}"
}

#wget  [option]  [URL]

# Clear installation log & error
rm $EFX_INSTALLER_LOG_FILE
rm $EFX_INSTALLER_ERROR_FILE

# Show Menu
showMenu

while [ opt != '' ]
    do
    if [[ $opt = "" ]]; then 
            exit;
    else
        case $opt in
        1) clear
        	option_picked "you chose to Install new Baxter release"
        	upload2Satellite Baxter 2>$EFX_INSTALLER_ERROR_FILE
        	sleep 2
        	showMenu
        	;;

        2) clear
            option_picked "you chose to Install new Baxter Air release"
            upload2Satellite Baxter_Air 2>$EFX_INSTALLER_ERROR_FILE
            sleep 2
        	showMenu
            ;;

        3) clear
            option_picked "you chose to Install new Cerebro release"
        	upload2Satellite Cerebro 2>$EFX_INSTALLER_ERROR_FILE
        	sleep 2
            showMenu
            ;;

        4) clear
            option_picked "you chose to Install new Caplin release"
        	upload2Satellite Caplin 2>$EFX_INSTALLER_ERROR_FILE
        	sleep 2
            showMenu
            ;;

        x) clear
        	exit
        	;;

        \n) clear
        	exit
        	;;

        *) clear
        	option_picked "Pick an option from the menu";
        	showMenu
        	;;
    	esac
	fi
done


