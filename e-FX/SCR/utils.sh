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
# http://stackoverflow.com/questions/16487258/how-to-declare-2d-array-in-bash
# Usage: utils.getMachine $1 $2
# $1: Service
# $1: Environment
function utils.getMachineFromDeployEnvConf(){
	# Asks for a Process
	readProccess
	# Ask for a Deployment Environment
	readDeploymentEnvironment

	TARGET_MACHINE=""
	TARGET_PORT=""
	  
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
	  if [ "$PROCESS" == "${ENV_PROCESSES[targetProcess]}" ] && [ "$ENV" == "${EFX_ENVIRONMENTS[targetEnv]}" ]; then
	  	TARGET_MACHINE="$HOST_MACHINE"
	  	TARGET_PORT="$PORT"
	  fi
	done  
	utils.logResult "${ENV_PROCESSES[targetProcess]} on ${EFX_ENVIRONMENTS[targetEnv]} runs on: $TARGET_MACHINE Machine on Port: $TARGET_PORT"
	#return $TARGET_MACHINE
}

# Asks for a Process
#Usage: readProccess
function readProccess(){
	echo "Select one of the following Processes >..."
	count=${#ENV_PROCESSES[@]}; #echo "SIZE: $count"
	for ((i=1; i<$count; i++))
	do
		echo -e "$i) ${ENV_PROCESSES[i]}"
	done
	read targetProcess
}

# Asks for a Deployment Environment
#Usage: readProccess
function readDeploymentEnvironment(){
	echo "Select one of the following Environments >..."
	count=${#EFX_ENVIRONMENTS[@]}; #echo "SIZE: $count"
	for ((i=1; i<$count; i++))
	do
		echo -e "$i) ${EFX_ENVIRONMENTS[i]}"
	done
	read targetEnv
}