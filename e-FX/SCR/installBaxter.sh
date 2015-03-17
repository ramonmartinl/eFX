################################################################################
#!/bin/env bash
#
# Script for installing Baxter Releases
#
# Usage: installBaxter.sh
#
# Author: Ramon Martin Lopez [ramn.martn@servexternos.isban.es]
# Since: 17/03/2015 
# Last Modified: 17/03/2015 (ramn.martn)
#
###############################################################################

# Components
# Baxter SBP Framework (sgbm-caplin-deploymentframework-x.y.z-wwww.x86_64.rpm)
# Baxter SBP Liberator (sgbm-caplin-liberator-x.y.z-wwww.x86_64.rpm)
# Baxter SBP Adapters (sgbm-caplin-adapters-x.y.z-wwww.x86_64.rpm)
#
# Santander WAR (santandertrader-x.y.z-wwww.war)

TRADEMODELS=false

# Installs a Baxter new Release
# Usage: installBaxter.installBaxter
function installBaxter.installBaxter(){
	TARGET_MACHINE="${ENV_MACHINES_SBANKD[6]}"
	#caller 0
	#su - efxbuild -c 'ask4BaxterReleaseDetails' 
	#exec 6<&0; exec < input.test
	ask4BaxterReleaseDetails
	#exec 0<&6 6<&-
	#RETVAL=1
	if [ $RETVAL = 0 ]; then
		baxterTasks.stopBaxter $TARGET_MACHINE
	fi
	if [ $RETVAL = 0 ]; then
		backupConfiguration $TARGET_MACHINE
	fi
	if [ $RETVAL = 0 ]; then
		removeLogLink $TARGET_MACHINE
	fi
	if [ $RETVAL = 0 ]; then	
		installBaxterRPMPackages
	fi	 
	if [ $RETVAL = 0 ]; then
		replaceConstansLicenceFile $TARGET_MACHINE
	fi	
	#RETVAL = 0
	if [ $RETVAL = 0 ]; then
		utils.logFinalResultOK "SUCCESSFULLY INSTALLED Baxter.$RELEASE_NUMBER RELEASE IN $TARGET_MACHINE"
	else
		utils.logFinalResultKO "Baxter.$RELEASE_NUMBER RELEASE FAILED TO INSTALL IN $TARGET_MACHINE"
	fi
}

# Read new Baxter Release Details from Console
function ask4BaxterReleaseDetails() {
	# Introduce Release Number
	echo -n "Please introduce new Release number, Ej.: 1.2.1 > "
	read releaseNumber
	RELEASE_NUMBER=$releaseNumber
	RELEASE_FOLDER=$UPLOAD_AREA_FOLDER/Baxter.$RELEASE_NUMBER
	option_picked "\nYou chose to install new release: Baxter.$RELEASE_NUMBER"
	if [ -n $releaseNumber ]; then 
		utils.logResultOK "New Baxter Release Properties introduced successfully"
		RETVAL=0
	else RETVAL=1	
	fi	
}

# Backup Configuration files and folders
# Usage: backupConfiguration $1
# $1: $TARGET_MACHINE
function backupConfiguration() {
	declare -x WORK_FOLDER=/opt/baxter/webpages/dashboard
	declare -x BACK_FOLDER=/opt/baxter/bak
	declare -x REMOTE_BAXTER_COMMAND="
		. .bash_profile;
		cd $WORK_FOLDER;
		cp config.cfg $BACK_FOLDER/config.cfg;
		exitcode=\$?;
		if [ \$exitcode = 0 ]; then
			echo 'Backup of config.cfg file SUCCESS';
		else
			echo 'Backup of config.cfg file FAILURE';
			exit \$exitcode;"
		fi;
		cp -rf locale $BACK_FOLDER;
		exitcode=\$?;
		if [ \$exitcode = 0 ]; then
			echo 'Backup of locale folder SUCCESS';
		else
			echo 'Backup of locale folder FAILURE';
			exit \$exitcode;"
		fi;
		exit \$exitcode;"
	
	echo "$REMOTE_BAXTER_COMMAND"	
	ssh "$USER_BAXTER@$TARGET_MACHINE" "$REMOTE_BAXTER_COMMAND"
	if [ $? = 0 ]; then
		utils.logResultOK "CONFIGURATION FILES SAVED IN $TARGET_MACHINE"
		RETVAL=0
	else 
		utils.logResultKO "CONFIGURATION FILES FAILED TO BE SAVED IN $TARGET_MACHINE"
		RETVAL=1	
	fi
}

# Remove Log Symbolic Link
# Usage: removeLogLink $1
# $1: $TARGET_MACHINE
function removeLogLink() {
	declare -x WORK_FOLDER=/opt/baxter
	declare -x REMOTE_BAXTER_COMMAND="
		. .bash_profile;
		cd $WORK_FOLDER;
		unlink log; 
		exitcode1=\$?;
		if [ \$exitcode1 = 0 ]; then
			echo 'log Unlinked SUCCESS';
		else
			echo 'log Unlinked FAILURE';
			exit \$exitcode1;
		fi;
		rmdir log;
		exitcode2=\$?;
		if [ \$exitcode2 = 0 ]; then
			echo 'log removed SUCCESS';
		else
			echo 'log removed FAILURE';
		fi;
		exit \$exitcode1;"
	
	echo "$REMOTE_BAXTER_COMMAND"	
	ssh "$USER_BAXTER@$TARGET_MACHINE" "$REMOTE_BAXTER_COMMAND"
	if [ $? = 0 ]; then
		utils.logResultOK "CONFIGURATION FILES SAVED IN $TARGET_MACHINE"
		RETVAL=0
	else 
		utils.logResultKO "CONFIGURATION FILES FAILED TO BE SAVED IN $TARGET_MACHINE"
		RETVAL=1	
	fi
}

# Install RPM Packages
# Usage: installBaxterRPMPackages
function installBaxterRPMPackages() {
	#declare -x rpmsToInstall=$(ls $RELEASE_FOLDER | grep rpm | awk '{ ORS=" "; print; }')
	# Install from Satellite using release number (X.Y.*, X.*)
	declare -x firtNumber="$RELEASE_NUMBER" | cut -d'.' -f 1
	declare -x secondNumber="$RELEASE_NUMBER" | cut -d'.' -f 2
	declare -x thirdNumber="$RELEASE_NUMBER" | cut -d'.' -f 3
	declare -x rpmsToInstall="baxter-*$firtNumber.$secondNumber*"
	if [ -n "$rpmsToInstall" ]; then
		utils.logResult "Baxter RPMS To install: $rpmsToInstall"
		utils.installRPMPackages "$rpmsToInstall"
	else 
		utils.logResult "No Baxter RPMS found To install"	
		RETVAL=1
	fi
}

# REplace constants.licence File
# Usage: replaceConstansLicenceFile
replaceConstansLicenceFile() {
	declare -x WORK_FOLDER=/opt/baxter/config-server/repository/com/baxter/pe
	declare -x REMOTE_BAXTER_COMMAND="
		. .bash_profile;
		cd $WORK_FOLDER;
		mv constants.license constants.bak 
		exitcode=\$?;
		if [ \$exitcode = 0 ]; then
			echo 'Backup of constants.license file SUCCESS';
		else
			echo 'Backup of constants.license file FAILURE';
			exit \$exitcode;
		fi;
		cp $RELEASE_FOLDER/constants.license_nonHA constants.license;
		exitcode=\$?;
		if [ \$exitcode = 0 ]; then
			echo 'Update of constants.license file SUCCESS';
		else
			echo 'Update of constants.license file FAILURE';
			exit \$exitcode;"
		fi;
		exit \$exitcode;"
	
	echo "$REMOTE_BAXTER_COMMAND"	
	ssh "$USER_BAXTER@$TARGET_MACHINE" "$REMOTE_BAXTER_COMMAND"
	if [ $? = 0 ]; then
		utils.logResultOK "constants.license FILE REPLACED IN $TARGET_MACHINE"
		RETVAL=0
	else 
		utils.logResultKO "constants.license FILE FAILED TO BE REPLACED IN $TARGET_MACHINE"
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

# Decompresses santandertrader.x.y.z.tar.gz in /home/efxbuild/upload_area/Baxter.x.y.z
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
# Hints: file is located in /opt/baxter/config-server/repository/com/baxter/pe/Baxter/config-trades folder
function updateTradeModelsFile(){
	declare -x REMOTE_CAPLIN_COMMAND="
		pushd /opt/baxter/config-server/repository/com/baxter/pe/Baxter/config-trades;
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
