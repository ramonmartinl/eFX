################################################################################
#!/bin/env bash
#
# Script for installing Caplin Releases
#
# Usage: installCaplin.sh
#
# Author: Ramon Martin Lopez [ramn.martn@servexternos.isban.es]
# Since: 10/03/2015 
# Last Modified: 13/03/2015 (ramn.martn)
#
###############################################################################

# Components
# Caplin SBP Framework (sgbm-caplin-deploymentframework-x.y.z-wwww.x86_64.rpm)
# Caplin SBP Liberator (sgbm-caplin-liberator-x.y.z-wwww.x86_64.rpm)
# Caplin SBP Adapters (sgbm-caplin-adapters-x.y.z-wwww.x86_64.rpm)
#
# Santander WAR (santandertrader-x.y.z-wwww.war)

TRADEMODELS=false

# Installs a Caplin new Release
# Usage: installCaplin.installCaplin
function installCaplin.installCaplin(){
	TARGET_MACHINE="${ENV_MACHINES_SBANKD[6]}"
	#caller 0
	#su - efxbuild -c 'ask4CaplinReleaseDetails' 
	#ask4CaplinReleaseDetails < input.test
	ask4CaplinReleaseDetails
	#RETVAL=1
	if [ $RETVAL = 0 ]; then
		caplinTasks.stopCaplin $TARGET_MACHINE
	fi
	if [ $RETVAL = 0 ]; then	
		installCaplinRPMPackages
	fi	 
	if [ $RETVAL = 0 ]; then
		caplinTasks.versionsCaplin $TARGET_MACHINE
	fi	
	if [ $RETVAL = 0 ]; then
		caplinTasks.startCaplin $TARGET_MACHINE
	fi	
	if [ $RETVAL = 0 ]; then
		caplinTasks.statusCaplin $TARGET_MACHINE
	fi
	if [ $RETVAL = 0 ]; then	
		decompressWar
	fi
	if [ $RETVAL = 0 ]; then
		stopTomcat $TARGET_MACHINE
	fi	
	if [ $RETVAL = 0 ]; then
		deployWar $TARGET_MACHINE
	fi	
	if [ $RETVAL = 0 ]; then
		startTomcat $TARGET_MACHINE
	fi	
	if [ $RETVAL = 0 ]; then
		checkSantandertraderFile $TARGET_MACHINE
	fi	
	if [ $RETVAL = 0 ] && [ $TRADEMODELS = true ]; then
		echo "Update trademodels.xml file"
		updateTradeModelsFile
	fi
	#RETVAL = 0
	if [ $RETVAL = 0 ] && [ $TRADEMODELS = true ]; then
		echo "restartBaxterBroadcast..."
		#restartBaxterBroadcast
	fi		
	if [ $RETVAL = 0 ]; then
		utils.logFinalResultOK "SUCCESSFULLY INSTALLED Caplin.$RELEASE_NUMBER RELEASE IN $TARGET_MACHINE"
	else
		utils.logFinalResultKO "Caplin.$RELEASE_NUMBER RELEASE FAILED TO INSTALL IN $TARGET_MACHINE"
	fi
}

# Read new Caplin Release Details from Console
function ask4CaplinReleaseDetails() {
	# Introduce Release Number
	#exec 6<&0; exec < input.test
	echo -n "Please introduce new Release number, Ej.: 1.2.1 > "
	read releaseNumber
	echo -n "Do you want to Update Baxter´s trademodels.xml file? Yes[y], No[n] > "
	read -n1 opt_trademodels
	#exec 0<&6 6<&-
	RELEASE_NUMBER=$releaseNumber
	RELEASE_FOLDER=$UPLOAD_AREA_FOLDER/Caplin.$RELEASE_NUMBER
	option_picked "\nYou chose to install new release: Caplin.$RELEASE_NUMBER"
	while [ opt_trademodels != '' ]
	    do
	        case $opt_trademodels in
	        y) 
	        # No Fixed Version
	        	option_picked "\nyou chose to update Baxter´s trademodels.xml file"
	        	sleep 1
	        	TRADEMODELS=true
	        	break
	        	;;
	        
	        n) 
	        # Fixed Version
	            option_picked "\nyou chose not to update Baxter´s trademodels.xml file"
	            sleep 1
	            TRADEMODELS=false
	            break
	            ;;
	
	        *) 
	        	#echo -n ""
	        	option_picked "\nSorry, you must enter a valid option: Yes[y], No[n] > ";
	        	read -n1 opt_trademodels
	        	;;
	    	esac
	done
	if [ -n $releaseNumber ] && [ -n $opt_trademodels ]; then 
		utils.logResultOK "New Caplin Release Properties introduced successfully"
		RETVAL=0
	else RETVAL=1	
	fi	
}

# Install RPM Packages
# Usage: installCaplinRPMPackages
function installCaplinRPMPackages() {
	#rpmsToInstall=$(ls $RELEASE_FOLDER | grep rpm | awk '{ ORS=" "; print; }')
	declare -x deploymentframeworkRPMToInstall=$(ls $RELEASE_FOLDER | grep sgbm-caplin-deploymentframework | awk '{ ORS=" "; print; }')
	declare -x liberatorRPMToInstall=$(ls $RELEASE_FOLDER | grep sgbm-caplin-liberator | awk '{ ORS=" "; print; }')
	declare -x adaptersRPMToInstall=$(ls $RELEASE_FOLDER | grep sgbm-caplin-adapters | awk '{ ORS=" "; print; }')
	declare -x rpmsToInstall="$deploymentframeworkRPMToInstall $liberatorRPMToInstall $adaptersRPMToInstall"
	if [ -n "$rpmsToInstall" ]; then
		utils.logResult "Caplin RPMS To install: $rpmsToInstall"
		utils.installRPMPackages "$rpmsToInstall"
		if [ $? = 0 ]; then
			RETVAL=0
		else
			RETVAL=1
		fi	
	else 
		utils.logResult "No Caplin RPMS found To install"	
		RETVAL=1
	fi
}


# Checks the existence of /local/vendor/tomcat7/tomcat/conf/Catalina/localhost/santandertrader.xml
# Usage: checkSantandertraderFile $1
# $1: $targetMachine
function checkSantandertraderFile(){
	# operate the process
	declare -r CATALINA_FOLDER=/local/vendor/tomcat7/tomcat/conf/Catalina
	declare -x REMOTE_CAPLIN_COMMAND="
		pushd $CATALINA_FOLDER/localhost;
		if [ -f santandertrader.xml ]; then
			exitcode=0;
			exit \$exitcode;
		else	
		 	cp $CATALINA_FOLDER/santandertrader.xml . ;
		 	exitcode=\$?;
			exit \$exitcode;
		fi;
		popd"
			
	#echo "$REMOTE_CAPLIN_COMMAND"
	selectTargetMachine "$1"
			      	
	ssh "$USER_TOMCAT7@$TARGET_MACHINE" "$REMOTE_CAPLIN_COMMAND"
	if [ $? = 0 ]; then
		utils.logResultOK "santandertrader.xml FILE CHECKED IN $TARGET_MACHINE"
		RETVAL=0
	else 
		utils.logResultKO "problem with santandertrader.xml FILE IN $TARGET_MACHINE"
		RETVAL=1	
	fi	
}

# Decompresses santandertrader.x.y.z.tar.gz in /home/efxbuild/upload_area/Caplin.x.y.z
# Usage: decompressWar
function decompressWar(){
	pushd $RELEASE_FOLDER
	declare -x santanderTraderWar=$(ls santandertrader-war-$RELEASE_NUMBER*.tar.gz)
	popd
	#echo "$santanderTraderWar"
	declare -x REMOTE_CAPLIN_COMMAND="
		pushd $RELEASE_FOLDER;
		if [ -f $santanderTraderWar ]; then
			tar -xvf $santanderTraderWar;
			exitcode=\$?;
			exit \$exitcode;
		else
			exitcode=1;
			exit \$exitcode;
		fi;	
		popd"
		
	#echo "$REMOTE_CAPLIN_COMMAND"
	ssh "$USER_EFXBUILD@${ENV_MACHINES_SPECIAL[0]}" "$REMOTE_CAPLIN_COMMAND"
	if [ $? = 0 ]  &&  [ -f $RELEASE_FOLDER/santandertrader-war/santandertrader.war ]; then
		utils.logResultOK "$santanderTraderWar FILE DECOMPRESSED SUCCESSFULLY IN $RELEASE_FOLDER/santandertrader-war/santandertrader.war"
		RETVAL=0
	else	
		utils.logResultKO "$santanderTraderWar FILE FAILED TO DECOMPRESS"
		RETVAL=1
	fi	
}

# Deploys santandertrader.x.y.z.tar.gz in Tomcat
# Usage: deployWar $1
# $1: $targetMachine
function deployWar(){
	declare -r CATALINA_FOLDER=/local/vendor/tomcat7/tomcat/conf/Catalina
	declare -x REMOTE_CAPLIN_COMMAND="
		pushd $CATALINA_FOLDER/localhost;
		if [ -f santandertrader.xml ]; then
			cp santandertrader.xml  $CATALINA_FOLDER/santandertrader.xml;
		fi;
		popd;
		pushd /local/vendor/tomcat7/tomcat/webapps;
		if [ -f santandertrader.war.bak ]; then
			rm santandertrader.war.bak;
		fi;
		mv santandertrader.war santandertrader.war.bak;
		if [ -d santandertrader.bak ]; then
			rm -rf santandertrader.bak;
		fi;	
		mv santandertrader santandertrader.bak;
		cp $RELEASE_FOLDER/santandertrader-war/santandertrader.war . ;
		exitcode=\$?;
		exit \$exitcode;
		popd"
	
	#echo "$REMOTE_CAPLIN_COMMAND"	
	selectTargetMachine "$1"
	
	ssh "$USER_TOMCAT7@$TARGET_MACHINE" "$REMOTE_CAPLIN_COMMAND" 
	if [ $? = 0 ]; then
		utils.logResultOK "santandertrader.war DEPLOYED SUCCESSFULLY IN $TARGET_MACHINE"
		RETVAL=0
	else
		utils.logResultKO "santandertrader.war FAILED TO BE DEPLOYED IN $TARGET_MACHINE"
		RETVAL=1
	fi	
}

# Restarts Tomcat
# Usage: restartTomcat $1
# $1: $targetMachine
function restartTomcat(){
	stopTomcat "$1"
	startTomcat "$1"
}

# Starts Tomcat
# Usage: startTomcat $1
# $1: $targetMachine
function startTomcat(){
	declare -x REMOTE_CAPLIN_COMMAND="
		pushd /local/vendor/tomcat7/tomcat/bin;
		./startup.sh;
		exitcode=\$?;
		exit \$exitcode;
		popd"
		
	#echo "$REMOTE_CAPLIN_COMMAND"
	selectTargetMachine "$1"
	
	ssh "$USER_TOMCAT7@$TARGET_MACHINE" "$REMOTE_CAPLIN_COMMAND"
	if [ $? = 0 ]; then
		utils.logResultOK "Tomcat STARTED SUCCESSFULLY IN $TARGET_MACHINE"
		RETVAL=0
	else
		utils.logResultKO "Tomcat FAILED TO START IN $TARGET_MACHINE"
		RETVAL=1
	fi	
}

# Stops Tomcat
# Usage: stopTomcat $1
# $1: $targetMachine
function stopTomcat(){
	declare -x REMOTE_CAPLIN_COMMAND="
		pushd /local/vendor/tomcat7/tomcat/bin;
		./shutdown.sh;
		exitcode=\$?;
		exit \$exitcode;
		popd"
		
	#echo "$REMOTE_CAPLIN_COMMAND"
	selectTargetMachine "$1"
	
	ssh "$USER_TOMCAT7@$TARGET_MACHINE" "$REMOTE_CAPLIN_COMMAND"
	if [ $? = 0 ]; then
		utils.logResultOK "Tomcat STOPPED SUCCESSFULLY IN $TARGET_MACHINE"
		RETVAL=0
	else
		utils.logResultKO "Tomcat FAILED TO STOP IN $TARGET_MACHINE"
		RETVAL=1
	fi 	
}

# Updates trademodels.xml
# Usage: updateTradeModelsFile
# Hints: file is located in /opt/baxter/config-server/repository/com/baxter/pe/Caplin/config-trades folder
function updateTradeModelsFile(){
	declare -x REMOTE_CAPLIN_COMMAND="
		pushd /opt/baxter/config-server/repository/com/baxter/pe/Caplin/config-trades;
		cp trademodels.xml trademodels.xml.bak;
		if [ -f $RELEASE_FOLDER/trademodels.xml ]; then
			cp $RELEASE_FOLDER/trademodels.xml . ;
			exitcode=\$?;
			exit \$exitcode; 
		else
			exitcode=1;
			exit \$exitcode;
		fi;
		popd"
	
	echo "$REMOTE_CAPLIN_COMMAND"
	TARGET_MACHINE="${ENV_MACHINES_SBANKD[7]}"
	
	ssh "$USER_BAXTER@$TARGET_MACHINE" "$REMOTE_CAPLIN_COMMAND"
	if [ $? = 0 ]; then
		utils.logResultOK "trademodels.xml FILE UPDATED SUCCESSFULLY IN $TARGET_MACHINE"
		RETVAL=0
	else
		utils.logResultKO "FAILED TO UPDATE trademodels.xml FILE IN $TARGET_MACHINE"
		RETVAL=1
	fi
}

# Restarts Baxter Broadcast 
# Usage: restartBaxterBroadcast
function restartBaxterBroadcast(){
	echo "test"
	TARGET_MACHINE="${ENV_MACHINES_SBANKD[7]}"
	baxterTasks.stopBaxterBroadcast
	baxterTasks.startBaxterBroadcast
}

# Selects the target Machine if not specified
# Usage: selectTargetMachine $1
# $1: $targetMachine
function selectTargetMachine(){
	if [ -z "$1" ]; then	
			echo "Enter the Machine to operate ${ENV_MACHINES_SBANKD[5]} [1], ${ENV_MACHINES_SBANKD[6]} [2] >"
			read target_caplin
			case $target_caplin in
		        
		        1)
		        # ENV_MACHINES_SBANKD[5]
		        	TARGET_MACHINE="${ENV_MACHINES_SBANKD[5]}"
		        	;;
		        	
		        2)
		        # ENV_MACHINES_SBANKD[6
		        	TARGET_MACHINE="${ENV_MACHINES_SBANKD[6]}"
		        	;;
		        	
			esac  
	else TARGET_MACHINE="$1"
	fi
}
