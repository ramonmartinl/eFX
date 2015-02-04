#!/bin/env bash

### FUNCTIONS ###
# Param 1 is the return code. Param 2 is text to display on failure
function checkErrors {
  if [ "${1}" -ne "0" ]; then
    echo "ERROR # Return code = ${1} : ${2}" >&2
    # Exit with the right error code
    exit ${1}
  fi
}

usage=$'\nusage: release.sh [OPTIONS]\n\nOPTIONS:\n\n-h Show usage\n-d <dir> Absolute directory to prepare the release\n-b <branch> Development branch to be released\n-e <env> Development environment to do the release\n-r <tag> Name of the repository tag to be created with the source code of the release. Tag shouldn\'t exist before\n-m <message> Commit message to all the commits of the release process\n-v <version> Version of the release. If not set, the release will have the next version of the development branch\n-p <previousTag> Previous released tag. Used to list the modules which need to be deployed\n-t Executes the tests\n-s Executes the sbar generation'
script=$(readlink -f "$0")
scriptpath=$(dirname "$script")
repositoryRoot="https://gblonxa080/svn/eFX-Development/eFX"
skipTest=true
skipSbar=true

#Read the release properties file
cd $scriptpath
. ./release.properties

#Read the properties from the command line
while getopts "d:b:e:r:m:v:p:sth" option
do
  case $option in
    d)
	 installDir=$OPTARG
	 ;;
	b)
	 branchName=$OPTARG
	 ;;
	e)
	 devName=$OPTARG
	 ;;
	r)
	 tagName=$OPTARG
	 ;;
	m)
	 commitMsg=$OPTARG
	 ;;
	v)
	 fixedVersion=$OPTARG
	 ;;
	p)
	 previousTag=$OPTARG
	 ;;
	s)
	skipSbar=false
	;;
	t)
	skipTest=false
	;;
    ?)
	 echo "$usage"
	 exit 1
	 ;;
  esac
done

#Usage tests

if ! [ -d $installDir ]; then
  echo "You should set the installDir to the absolute path of an existing directory. You can do it either in the release.properties configuration file or with the -d option" >&2
  exit 1
fi

if [ "$devName" != "DEV1" ] && [ "$devName" != "DEV3" ] && [ "$devName" != "DEV4" ] && [ "$devName" != "SIT1" ]; then
  echo "You should set the devName to a valid development environment (DEV1, DEV3, DEV4 or SIT1). You can do it either in the release.properties configuration file or with the -e option" >&2
  exit 1
fi

#SVN Checkout
svn co $repositoryRoot/branches/$branchName $installDir
checkErrors ${PIPESTATUS[0]} "SVN Error while executing checkout"
dos2unix $installDir/Linux/scripts/*.sh
chmod +x $installDir/Linux/scripts/*.sh
echo CHECKOUT COMPLETED IN DIR: $installDir

#Configuring environment
eval `/opt/streambase7/bin/sb-config --env`
cd $installDir/Linux/scripts
echo "Calling env_build.sh with database vars for $devName"
. env_build.sh $installDir $devName release

#Retrieving release version 
cd $installDir/parent
retrievedVersion=$(grep -m 1 version pom.xml | awk -F'>' '{print $2}' | awk -F'<' '{print $1}')
if [ -z ${fixedVersion+x} ]; then
  releaseVersion=$(echo $retrievedVersion | tr -d '\-SNAPSHOT')
  futureVersion=$(echo $retrievedVersion| rev | sed 's/^[^\.]*\.//' | rev).$(($(echo $retrievedVersion | awk -F'.' '{print $NF}')+1))-SNAPSHOT
  else
  releaseVersion=$fixedVersion
  futureVersion=$retrievedVersion
fi

echo Current branch version is ${retrievedVersion} 
echo Release version is ${releaseVersion} 
echo Branch will have version ${futureVersion} after the release

#Updating poms to release version
cd $scriptpath
. update-cerebro-version.sh $installDir $releaseVersion
checkErrors ${PIPESTATUS[0]} "Error updating Cerebro version to release version $releaseVersion"

#Deploying the release

#Cerebro parent
echo Calling maven clean deploy for Cerebro parent
cd $installDir/parent
mvn clean deploy -e -U -P release -Dmaven.test.skip=true | tee deploy-build.log
checkErrors ${PIPESTATUS[0]} "Maven error. Maven clean deploy for Cerebro parent finished with compile errors. See $installDir/parent/deploy-build.log"
echo Maven clean deploy successfully executed for Cerebro parent

#Java modules
echo Calling maven clean deploy for Java modules
cd $installDir/java/modules
mvn clean deploy -e -U -P release -Dmaven.test.skip=$skipTest | tee deploy-build.log
checkErrors ${PIPESTATUS[0]} "Maven error. Maven clean deploy for Java modules finished with compile errors. See $installDir/java/modules/deploy-build.log"
echo Maven clean deploy successfully executed for Java modules

#Java modules JDK 1.6
echo Calling maven clean deploy for Java modules with JDK 1.6
cd $installDir/java/modules
mvn clean deploy -e -U -Dmaven.test.skip=true -P jdk16 -P release | tee deploy-build-jdk16.log
checkErrors ${PIPESTATUS[0]} "Maven error. Maven clean deploy for Java modules JDK 1.6 finished with compile errors. See $installDir/java/modules/deploy-build-jdk16.log"
echo Maven clean deploy successfully executed for Java modules with JDK 1.6

#eFX-SB7-Modules JDK 1.6		
echo Calling maven clean deploy for eFX-SB7-Modules with JDK 1.6
cd $installDir/SB7/eFX-Modules
mvn clean deploy -e -X -U -Dmaven.test.skip=true -P jdk16 | tee deploy-build-jdk16.log
checkErrors ${PIPESTATUS[0]} "Maven error. Maven clean deploy for eFX-SB7-Modules JDK 1.6 finished with compile errors. See $installDir/SB7/eFX-SB7-Common/deploy-build-jdk16.log"
echo Maven clean deploy successfully executed for eFX-SB7-Modules with JDK 1.6

#eFX-SB7-Modules
echo Calling maven clean deploy for eFX-SB7-Modules
cd $installDir/SB7/eFX-Modules
mvn clean deploy -e -U -P release -Dmaven.test.skip=$skipTest -Dsbar-generator.streambaseBinFolder=bin -Dsbar-generator.skip=$skipSbar | tee deploy-build.log
checkErrors ${PIPESTATUS[0]} "Maven error. Maven clean deploy for eFX-SB7-Modules finished with compile errors. See $installDir/SB7/eFX-Modules/deploy-build.log"
echo Maven clean deploy successfully executed for eFX-SB7-Modules

#Generate support tools rpm
cd $installDir/java/support-tools
mvn -e -X -U rpm:rpm
cd $installDir/java/support-tools/target/rpm/sgbm-efx-support-tools/RPMS/x86_64
/bin/cp -f *.rpm /home/efxbuild/upload_area_sit/

#Create release tag
if [ -z ${fixedVersion+x} ]; then
  cd $installDir
  svn commit -m "$commitMsg"
  checkErrors ${PIPESTATUS[0]} "SVN error when committing release version to development branch"
  echo Commited version $releaseVersion to branch $branchName to generate tag
  
  #Create release tag
  echo "Performing svn tag $tagName for branch $branchName with commit message $commitMsg"
  svn cp -rHEAD -m "$commitMsg" $repositoryRoot/branches/$branchName $repositoryRoot/tags/$tagName
  checkErrors ${PIPESTATUS[0]} "SVN error when committing release tag to repository"
  echo Release successfully completed. Tag $tagName commited
 else
  echo "Performing svn tag $tagName for branch $branchName with commit message $commitMsg"
  cd $installDir
  svn cp . $repositoryRoot/tags/$tagName -m "$commitMsg"
  checkErrors ${PIPESTATUS[0]} "SVN error when committing release tag to repository"
  echo Release successfully completed. Tag $tagName commited
fi

#Generating new development versions
if [ -z ${fixedVersion+x} ]; then
  cd $scriptpath
  . update-cerebro-version.sh $installDir $futureVersion
  checkErrors ${PIPESTATUS[0]} "Error updating Cerebro development version to $releaseVersion. Release artifacts has been successfully generated, but the version of the development branch should be checked."
  
  #Commit of new development version
  cd $installDir
  svn commit -m "$commitMsg"
  checkErrors ${PIPESTATUS[0]} " SVN error committing Cerebro development version to $releaseVersion in the development branch. Release artifacts has been successfully generated, but the version of the development branch should be checked."
  echo Commited version $futureVersion to branch $branchName for future development
fi

#Show the list of modified packages
showModulesToDeploy.py $branchName $previousTag