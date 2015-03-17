################################################################################
#!/bin/env bash
#
# Script for utilities
#
# Usage: utils.sh
#
# Author: Ramon Martin Lopez [ramn.martn@servexternos.isban.es]
# Since: 27/01/2015 
# Last Modified: 05/02/2015 (ramn.martn)
#
###############################################################################

# sends a message to the log file
# Usage: utils.logResult $1
# $1: Message
function utils.logResult(){
	echo -e "\n### $(date): "$1" " | tee --append $EFX_INSTALLER_LOG_FILE
}

# sends a success message to the log file
# Usage: utils.logResultOK $1
# $1: Message
function utils.logResultOK(){
	utils.logResult "${FMT_GREEN_TEXT}$1${FMT_NORMAL}"
}

# sends a Global success message to the log file
# Usage: utils.logFinalResultOK $1
# $1: Message
function utils.logFinalResultOK(){
	utils.logResult "${FMT_GREEN_BOLD_TEXT}$1${FMT_NORMAL}"
}

# sends a failure message to the log file
# Usage: utils.logResultKO $1
# $1: Message
function utils.logResultKO(){
	utils.logResult "${FMT_RED_TEXT}$1${FMT_NORMAL}"
}

# sends a Global failure message to the log file
# Usage: utils.logFinalResultKO $1
# $1: Message
function utils.logFinalResultKO(){
	utils.logResult "${FMT_RED_BOLD_TEXT}$1${FMT_NORMAL}"
}

# Executes a command as user 4 Build
# Usage: utils.executeAsBuild $1
# $1: Command to execute
function utils.executeAsBuild(){
	if [ "$USER" == "$USER_EFXBUILD" ]; then
		#/opt/boksm/bin/suexec -u $USER_EFXBUILD source $EFX_INSTALLER_HOME/installEFX.env;$1
		#su -m $USER_EFXBUILD -c 'source $EFX_INSTALLER_HOME/installEFX.env;$1'
		$1
	else
		utils.logResult "Sorry you can only execute this functionality as User: $USER_EFXBUILD"
		exit $ERROR_UNAUTHORIZED
	fi
} 

# Executes a command as user 4 Baxter
# Usage: utils.executeAsBaxter $1
# $1: Command to execute
function utils.executeAsBaxter(){
	if [ "$USER" == "$USER_BAXTER" ]; then
		#su -m $USER_BAXTER -c 'source $EFX_INSTALLER_HOME/installEFX.env;$1'
		$1
	else
		utils.logResult "Sorry you can only execute this functionality as User: $USER_BAXTER"
		exit $ERROR_UNAUTHORIZED
	fi
} 


# Executes a command as user 4 Streambase
# Usage: utils.executeAsStreambase $1
# $1: Command to execute
function utils.executeAsStreambase(){
	if [ "$USER" == "$USER_STRMBASE" ]; then
		#su -m $USER_STRMBASE -c 'source $EFX_INSTALLER_HOME/installEFX.env;$1'
		$1
	else
		utils.logResult "Sorry you can only execute this functionality as User: $USER_STRMBASE"
		exit $ERROR_UNAUTHORIZED
	fi
}

# Checks if is allowed to operate in a Host Machine
# Usage: utils.isAllowedHost $1
# $1: variable to evaluate
function utils.isAllowedHost(){
	declare -x hostMatched=false
	declare -x allowedHost=''
	count=${#ENV_MACHINES_ALLOWED[@]}; #echo "SIZE: $count"
	for ((i=0; i<$count; i++))
	do
		allowedHost=${ENV_MACHINES_ALLOWED[i]}
		#echo -n "hostname: $(hostname), allowedHost: $allowedHost"
		if  [ "$(hostname)" == "$allowedHost" ]; then
			hostMatched=true
		fi		
	done
	eval "$1='$hostMatched'"
	if [ $hostMatched = false ]; then
		utils.logResult "Sorry you can only execute this functionality from the following Hosts: ${ENV_MACHINES_ALLOWED[*]}"
		exit $ERROR_UNAUTHORIZED
	fi
}

# Create new Release Folder
# Usage: utils.createNewFolder $1
# $1: RELEASE_FOLDER
function utils.createNewFolder() {
	if [ ! -d "$1" ]; then
		mkdir $1
		utils.logResult "Created nonExistent $1 Folder successfully"
	else utils.logResult "$1 Folder already exists"
	fi

}

# Ask for new Release details
# Usage: utils.ask4SWReleaseDetails
# $1: variable to Evaluate
# return Release Folder
function utils.ask4SWReleaseDetails(){
	# Read Application name & Release Number from user input
	echo -n "Please introduce Application name, Options: Cerebro, Caplin, Baxter, etc.. > "
	read application
	echo -n "Please introduce Release number, Ej.: 3.4.29 > "
	read releaseNumber 
	releaseFolder="$UPLOAD_AREA_FOLDER/$application.$releaseNumber"
	#return "$releaseFolder"
	eval "$1='$releaseFolder'"
}

# Gets the machine that runs a service in deployment environment
# Usage: utils.getTargetMachine
function utils.getTargetMachine(){
	# Asks for a Process
	utils.readProccess
	# Ask for a Deployment Environment
	utils.getTargetConf
}


# Gets the machine that runs a service in deployment environment
# Usage: utils.getTargetMachine4LP
function utils.getTargetMachine4LP(){
	# Asks for a Process
	utils.readLP
	# Ask for a Deployment Environment
	utils.getTargetConf
}

# Gets the configuration in deployment environment
# http://stackoverflow.com/questions/16487258/how-to-declare-2d-array-in-bash
# Usage: utils.getTargetConf
function utils.getTargetConf(){
	# Ask for a Deployment Environment
	utils.readDeploymentEnvironment

	# Loop and print it.  Using offset and length to extract values
	count=${#DEPLOYMENT_ENVIRONMENTS_CONF[@]}; #echo "SIZE: $count"
	for ((i=0; i<$count; i++))
	do
		declare -a DEPLOY_ENV=${DEPLOYMENT_ENVIRONMENTS_CONF[i]}
		#echo ${#DEPLOY_ENV[*]}
		read -a DEPLOYMENT_ENVIRONMENT <<< "${!DEPLOY_ENV[0]}"
		ENV=${DEPLOYMENT_ENVIRONMENT[0]}
		PROCESS=${DEPLOYMENT_ENVIRONMENT[1]}
		PORT=${DEPLOYMENT_ENVIRONMENT[2]}
		HOST_MACHINE=${DEPLOYMENT_ENVIRONMENT[3]}
		#echo -e "\nENVIRONEMT: $ENV, PROCESS: $PROCESS, PORT: $PORT, HOST: $HOST_MACHINE"
		if [ "$PROCESS" != 'Caplin' ] && [ "$PROCESS" == "${EFX_PROCESSES[targetProcess]}" ] && [ "$ENV" == "${EFX_ENVIRONMENTS[targetEnv]}" ]; then
			TARGET_PROCESS="$PROCESS"; TARGET_ENV="$ENV"; TARGET_MACHINE="$HOST_MACHINE"; TARGET_PORT="$PORT"
		fi	
		if [ "$PROCESS" == 'Caplin' ] && [ "$ENV" == "${EFX_ENVIRONMENTS[targetEnv]}" ]; then
			TARGET_PROCESS="$PROCESS"; TARGET_ENV="$ENV"; TARGET_MACHINE="CAPLIN"
		fi
	done
	utils.logResult "${EFX_PROCESSES[targetProcess]} on ${EFX_ENVIRONMENTS[targetEnv]} runs on: $TARGET_MACHINE Machine on Port: $TARGET_PORT"
}

# Gets the configuration in deployment environment
# Usage: utils.getTargetBaxterConf
function utils.getTargetBaxterConf(){
	# Ask for a Deployment Environment
	utils.readDeploymentEnvironment

	# Loop and print it.  Using offset and length to extract values
	count=${#DEPLOYMENT_ENVIRONMENTS_CONF[@]}; #echo "SIZE: $count"
	for ((i=0; i<$count; i++))
	do
		declare -a DEPLOY_ENV=${DEPLOYMENT_ENVIRONMENTS_CONF[i]}
		#echo ${#DEPLOY_ENV[*]}
		read -a DEPLOYMENT_ENVIRONMENT <<< "${!DEPLOY_ENV[0]}"
		ENV=${DEPLOYMENT_ENVIRONMENT[0]}
		PROCESS=${DEPLOYMENT_ENVIRONMENT[1]}
		PORT=${DEPLOYMENT_ENVIRONMENT[2]}
		HOST_MACHINE=${DEPLOYMENT_ENVIRONMENT[3]}
		#echo -e "\nENVIRONEMT: $ENV, PROCESS: $PROCESS, PORT: $PORT, HOST: $HOST_MACHINE"
		if [ "$PROCESS" == 'Baxter' ] && [ "$ENV" == "${EFX_ENVIRONMENTS[targetEnv]}" ]; then
			TARGET_PROCESS="$PROCESS"; TARGET_ENV="$ENV"; TARGET_MACHINE="$HOST_MACHINE"; TARGET_PORT="$PORT"
		fi	
	done
	utils.logResult "Baxter on ${EFX_ENVIRONMENTS[targetEnv]} runs on: $TARGET_MACHINE Machine on Port: $TARGET_PORT"
}

# Asks for a Process
#Usage: utils.readProccess
function utils.readProccess(){
	echo "Select one of the following Processes >..."
	count=${#EFX_PROCESSES[@]}; #echo "SIZE: $count"
	for ((i=1; i<$count; i++))
	do
		echo -e "$i) ${EFX_PROCESSES[i]}"
	done
	read targetProcess
}

# Asks for an LP
#Usage: utils.readLP
function utils.readLP(){
	echo "Select one of the following LPs >..."
	count=${#EFX_PROCESSES[@]}; #echo "SIZE: $count"
	for ((i=1; i<$count; i++))
	do
		if [[ "${EFX_PROCESSES[i]}" =~ .*eFX-LP.* ]]; then
			echo -e "$i) ${EFX_PROCESSES[i]}"
		fi	
	done
	read targetProcess
}

# Asks for a Deployment Environment
#Usage: utils.readDeploymentEnvironment
function utils.readDeploymentEnvironment(){
	echo "Select one of the following Environments >..."
	count=${#EFX_ENVIRONMENTS[@]}; #echo "SIZE: $count"
	for ((i=1; i<$count; i++))
	do
		echo -e "$i) ${EFX_ENVIRONMENTS[i]}"
	done
	read targetEnv
}

# Read any option to Confirm process
# Usage: utils.listenConfirmation $1 $2
# $1: Menu To show
# $1: Menu To Listen
function utils.listenConfirmation(){
    echo -e "${FMT_ENTER_LINE}Please ${FMT_RED_TEXT}enter to exit. ${FMT_NORMAL}"
    read opt_confirm
	while [ opt_confirm != '' ]
	    do
		$1; $2
	done
}


# Install RPM Packages
# Usage: utils.installRPMPackages $1
# $1: package to install
function utils.installRPMPackages() {
	declare -x packageNames=''
	if [ -z "$1" ]; then
		ls "$RELEASE_FOLDER"
		#rpmsToInstall=$(ls $RELEASE_FOLDER | grep rpm | awk '{ ORS=" "; print; }')
		echo "Introduce package Names (separated by space) > "
		read packageNames
	else packageNames="$1"	
	fi	
	pushd "$RELEASE_FOLDER"
	/opt/boksm/bin/suexec -u root /usr/local/bin/efx-yum update "$packageNames" | tee --append $EFX_INSTALLER_LOG_FILE
	if [ $? = 0 ]; then
		utils.logResultOK "NEW RELEASE PACKAGES: $packageNames INSTALLED SUCCESSFULLY"
		RETVAL=0
	else 
		utils.logResultKO "NEW RELEASE PACKAGES: $packageNames FAILED TO INSTALL"
		RETVAL=1
	fi	
	popd
}