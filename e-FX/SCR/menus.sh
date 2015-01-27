################################################################################
#!/bin/env bash
#
# Script for showing menus
#
# Usage: menus.sh
#
# Author: Ramon Martin Lopez [ramn.martn@servexternos.isban.es]
# Since: 22/01/2015 
# Last Modified: 27/01/2015 (ramn.martn)
#
###############################################################################

#Format menu
FMT_NORMAL=`echo "\033[m"`; export $FMT_NORMAL
FMT_MENU=`echo "\033[36m"` #Blue; export $FMT_MENU
FMT_NUMBER=`echo "\033[33m"` #yellow; export $FMT_NUMBER
FMT_FGRED=`echo "\033[41m"`; export $FMT_FGRED
FMT_RED_TEXT=`echo "\033[31m"`; export $FMT_RED_TEXT
FMT_ENTER_LINE=`echo "\033[33m"`; export $FMT_ENTER_LINE

#Show option picked
function option_picked(){
    COLOR='\033[01;31m' # bold red
    RESET='\033[00;00m' # normal white
    MESSAGE=${@:-"${RESET}Error: No message passed"}
    echo -e "${COLOR}${MESSAGE}${RESET}"
}

#Main menu
showMainMenu(){
    clear
    echo -e "${FMT_MENU}#############################################${FMT_NORMAL}"
    echo -e "${FMT_MENU}# Welcome to the EFX Installation Program${FMT_NORMAL}"
    echo -e "${FMT_MENU}#############################################${FMT_NORMAL}"
    echo -e "${FMT_MENU}**${FMT_NUMBER} 1)${FMT_MENU} Build Cerebro ${FMT_NORMAL}"
    echo -e "${FMT_MENU}**${FMT_NUMBER} 2)${FMT_MENU} Install Baxter ${FMT_NORMAL}"
    echo -e "${FMT_MENU}**${FMT_NUMBER} 3)${FMT_MENU} Install Baxter Air ${FMT_NORMAL}"
    echo -e "${FMT_MENU}**${FMT_NUMBER} 4)${FMT_MENU} Install Cerebro ${FMT_NORMAL}"
    echo -e "${FMT_MENU}**${FMT_NUMBER} 5)${FMT_MENU} Install Caplin ${FMT_NORMAL}"
    echo -e "${FMT_MENU}**${FMT_NUMBER} 6)${FMT_MENU} Maintenance Tasks ${FMT_NORMAL}"
    echo -e "${FMT_MENU}*********************************************${FMT_NORMAL}"
    echo -e "${FMT_ENTER_LINE}Please enter a menu option and enter or ${FMT_RED_TEXT}enter to exit. ${FMT_NORMAL}"
    read opt_main
}

# Read options from Main Menu
function listenMainMenu(){
	while [ opt_main != '' ]
	    do
	    if [[ $opt_main = "" ]]; then 
	    		clear
	            exit 0;
	    else
	        case $opt_main in
	        1) clear
	        # BUILD CEREBRO
	        	option_picked "you chose to Build Cerebro Packages"
	        	buildCerebro.builCerebro 2>>$EFX_INSTALLER_ERROR_FILE
	        	showMainMenu
	        	;;
	        
	        2) clear
	        # INSTALL BAXTER
	        	option_picked "you chose to Install new Baxter release"
	        	upload2Satellite Baxter 2>$EFX_INSTALLER_ERROR_FILE
	        	sleep 2
	        	showMainMenu
	        	;;
	
	        3) clear
	        # INSTALL BAXTER AIR
	            option_picked "you chose to Install new Baxter Air release"
	            upload2Satellite Baxter_Air 2>$EFX_INSTALLER_ERROR_FILE
	            sleep 2
	        	showMainMenu
	            ;;
	
	        4) clear
	        # INSTALL CEREBRO
	            option_picked "you chose to Install new Cerebro release"
	            upload2Satellite Cerebro 2>$EFX_INSTALLER_ERROR_FILE
	        	sleep 2
	            showMainMenu
	            ;;
	
	        5) clear
	        # INSTALL CAPLIN
	            option_picked "you chose to Install new Caplin release"
	        	upload2Satellite Caplin 2>$EFX_INSTALLER_ERROR_FILE
	        	sleep 2
	            showMainMenu
	            ;;
	
	        6) clear
	        # MAINTENANCE TASKS
	            option_picked "you chose to Execute other Maintenance Tasks"
	            #switchUser_efxbuild
	            showMaintenanceTasksMenu
	            listenMaintenanceTasksMenu
	        	sleep 2
	            showMainMenu
	            ;;
	            
	        x) clear
	        	exit 0
	        	;;
	
	        \n) clear
	        	exit 0
	        	;;
	
	        *) clear
	        	option_picked "Pick an option from the menu";
	        	showMainMenu
	        	;;
	    	esac
		fi
	done
}

# Menu for building EFX Modules 
showBuildEFXModulesMenu(){
    clear
    echo -e "${FMT_MENU}*********************************************${FMT_NORMAL}"
    echo -e "${FMT_MENU}* Build Cerebro --> Select EFX Module to build ${FMT_NORMAL}"
    echo -e "${FMT_MENU}*********************************************${FMT_NORMAL}"
    echo -e "${FMT_MENU}**${FMT_NUMBER} 1)${FMT_MENU} Build All modules ${FMT_NORMAL}"
    echo -e "${FMT_MENU}**${FMT_NUMBER} 2)${FMT_MENU} Build eFX-AdaFIX ${FMT_NORMAL}"
    echo -e "${FMT_MENU}**${FMT_NUMBER} 3)${FMT_MENU} Build eFX-Adartenon ${FMT_NORMAL}"
    echo -e "${FMT_MENU}**${FMT_NUMBER} 4)${FMT_MENU} Build eFX-Adaxter ${FMT_NORMAL}"
    echo -e "${FMT_MENU}**${FMT_NUMBER} 5)${FMT_MENU} Build eFX-Aggregation ${FMT_NORMAL}"
    echo -e "${FMT_MENU}**${FMT_NUMBER} 6)${FMT_MENU} Build eFX-AutoCM ${FMT_NORMAL}"
    echo -e "${FMT_MENU}**${FMT_NUMBER} 7)${FMT_MENU} Build eFX-Cleansing ${FMT_NORMAL}"
    echo -e "${FMT_MENU}**${FMT_NUMBER} 8)${FMT_MENU} Build eFX-CustomerPricing ${FMT_NORMAL}"
    echo -e "${FMT_MENU}**${FMT_NUMBER} 9)${FMT_MENU} Build eFX-DashboardBridge ${FMT_NORMAL}"
    echo -e "${FMT_MENU}**${FMT_NUMBER} 10)${FMT_MENU} Build eFX-ForwardPricing ${FMT_NORMAL}"
    echo -e "${FMT_MENU}**${FMT_NUMBER} 11)${FMT_MENU} Build eFX-LP-Citi ${FMT_NORMAL}"
    echo -e "${FMT_MENU}**${FMT_NUMBER} 12)${FMT_MENU} Build eFX-LP-D3 ${FMT_NORMAL}"
    echo -e "${FMT_MENU}**${FMT_NUMBER} 13)${FMT_MENU} Build eFX-LP-DB ${FMT_NORMAL}"
    echo -e "${FMT_MENU}**${FMT_NUMBER} 14)${FMT_MENU} Build eFX-LP-FIX ${FMT_NORMAL}"
    echo -e "${FMT_MENU}**${FMT_NUMBER} 15)${FMT_MENU} Build eFX-LP-GS ${FMT_NORMAL}"
    echo -e "${FMT_MENU}**${FMT_NUMBER} 16)${FMT_MENU} Build eFX-LP-MF ${FMT_NORMAL}"
    echo -e "${FMT_MENU}**${FMT_NUMBER} 17)${FMT_MENU} Build eFX-LP-MTI ${FMT_NORMAL}"
    echo -e "${FMT_MENU}**${FMT_NUMBER} 18)${FMT_MENU} Build eFX-LP-UBS ${FMT_NORMAL}"
    echo -e "${FMT_MENU}**${FMT_NUMBER} 19)${FMT_MENU} Build eFX-Modules ${FMT_NORMAL}"
    echo -e "${FMT_MENU}**${FMT_NUMBER} 20)${FMT_MENU} Build eFX-NewTickStore ${FMT_NORMAL}"
    echo -e "${FMT_MENU}**${FMT_NUMBER} 21)${FMT_MENU} Build eFX-Pricetenon ${FMT_NORMAL}"
    echo -e "${FMT_MENU}**${FMT_NUMBER} 22)${FMT_MENU} Build eFX-Pricing ${FMT_NORMAL}"
    echo -e "${FMT_MENU}**${FMT_NUMBER} 23)${FMT_MENU} Build eFX-SB7-Common ${FMT_NORMAL}"
    echo -e "${FMT_MENU}**${FMT_NUMBER} 24)${FMT_MENU} Build eFX-SB7-Parent ${FMT_NORMAL}"
    echo -e "${FMT_MENU}**${FMT_NUMBER} 25)${FMT_MENU} Build eFX-SB7-Tools ${FMT_NORMAL}"
    echo -e "${FMT_MENU}**${FMT_NUMBER} 26)${FMT_MENU} Build eFX-TenorService ${FMT_NORMAL}"
    echo -e "${FMT_MENU}**${FMT_NUMBER} 27)${FMT_MENU} Build eFX-TickStore ${FMT_NORMAL}"
    echo -e "${FMT_MENU}**${FMT_NUMBER} 28)${FMT_MENU} Build eFX-TradeReports ${FMT_NORMAL}"
    echo -e "${FMT_MENU}**${FMT_NUMBER} 29)${FMT_MENU} Build eFX-Trading ${FMT_NORMAL}"
    echo -e "${FMT_MENU}**${FMT_NUMBER} 30)${FMT_MENU} Build eFX-Volatility ${FMT_NORMAL}"
    echo -e "${FMT_MENU}*********************************************${FMT_NORMAL}"
    echo -e "${FMT_ENTER_LINE}Please enter a menu option and enter or ${FMT_RED_TEXT}enter to exit. ${FMT_NORMAL}"
    read opt_efx_modules
}

# Read option from Build EFX Modules Menu
function listenBuildEFXModulesMenu(){
	while [ opt_efx_modules != '' ]
	    do
	    	case $opt_efx_modules in
	        "") clear
	        # EXIT Build EFX Modules Menu
	        	break
	        	;;
	        	
	        1) clear
	        # BUILD ALL MODULES
	        	option_picked "you chose to Build All eFX Modules"
	        	builCerebro.buildAllEFXModules
	        	sleep 2
	        	break
	        	;;
	        
	        2) clear
	        # BUILD eFX-AdaFIX MODULE
	            option_picked "you chose to Build eFX-AdaFIX Module"
	            builCerebro.buildEFXModule eFX-AdaFIX
	            sleep 2
	            showBuildEFXModulesMenu
	            ;;
	          	        
	        3) clear
	        # BUILD eFX-Adartenon MODULE
	            option_picked "you chose to Build eFX-Adartenon Module"
	            builCerebro.buildEFXModule eFX-Adartenon
	            sleep 2
	            showBuildEFXModulesMenu
	            ;;
	              	        
	        23) clear
	        # BUILD eFX-SB7-Common MODULE
	            option_picked "you chose to Build eFX-SB7-Common Module"
	        	builCerebro.buildEFXSB7CommonModules
	        	sleep 2
	        	showBuildEFXModulesMenu
	            ;;
	
	        *) clear
	        	option_picked "Pick an option from the menu";
	        	showBuildEFXModulesMenu
	        	;;
	    	esac
	done
}

# Menu for Other Maintenance Tasks
showMaintenanceTasksMenu(){
    clear
    echo -e "${FMT_MENU}*********************************************${FMT_NORMAL}"
    echo -e "${FMT_MENU}* Maintenance Tasks --> Other Maintenance Tasks ${FMT_NORMAL}"
    echo -e "${FMT_MENU}*********************************************${FMT_NORMAL}"
    echo -e "${FMT_MENU}**${FMT_NUMBER} 1)${FMT_MENU} Start LP Points Simulation ${FMT_NORMAL}"
    echo -e "${FMT_MENU}**${FMT_NUMBER} 2)${FMT_MENU} Upload Software to Satellite ${FMT_NORMAL}"
    echo -e "${FMT_MENU}*********************************************${FMT_NORMAL}"
    echo -e "${FMT_ENTER_LINE}Please enter a menu option and enter or ${FMT_RED_TEXT}enter to exit. ${FMT_NORMAL}"
    read opt_maintenance_tasks
}

# Read option from Maintenance Menu
function listenMaintenanceTasksMenu(){
	while [ opt_maintenance_tasks != '' ]
	    do
	    if [[ $opt_maintenance_tasks = "" ]]; then 
	            # Show Main Menu
				showMainMenu
				listenMainMenu
	    else
	        case $opt_maintenance_tasks in
	        1) clear
	        # START LP POINTS SIMULATION
	        	#option_picked "you chose to Build Start LP Points Simulation"
	        	#switchUser_efxbuild
	        	sleep 2
	        	showMaintenanceTasksMenu
	        	;;
	        
	        2) clear
	        # UPLOAD SW TO SATELLITE
	            option_picked "you chose to Upload Software to Satellite"
	            #switchUser_efxbuild
	            uploadSW2Satellite.upload2Satellite 2>$EFX_INSTALLER_ERROR_FILE
	        	sleep 2
	            showMaintenanceTasksMenu
	            ;;
	            
	        x) clear
	        	exit 0
	        	;;
	
	        \n) clear
	        	exit 0
	        	;;
	
	        *) clear
	        	option_picked "Pick an option from the menu";
	        	showMainMenu
	        	;;
	    	esac
		fi
	done
}
