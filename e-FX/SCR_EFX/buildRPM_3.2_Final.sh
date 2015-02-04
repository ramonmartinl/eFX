#!/bin/bash
# Only is used for SIT, and the the upload area used is the upload_area
#WARNING: upload_area is only used for UAT/Prod purpose

### Check build parameters, exit script if invalid 
if [ "$1" == "" ] || [ "$2" == "" ] || [ "$3" == "" ] || [ "$4" == "" ];  then 
   echo Format expected is: buildRPM.sh [version] [release] [deploy_dir] [module]
   exit 1
fi


### Init script variables 
export INSTALL_DIR=./eFX_install
export VERSION=$1
export RELEASE=$2
export EFX_ARCHIVE=eFX-$VERSION.tar.gz
#export MODULE=$4

if [ "$4" == "all" ]; then
for MODULE in `ls /home/efxbuild/eFX-Scripts/${VERSION}/SB7/ | grep -v eFX-SB7-Common | grep -v eFX-SB7-Parent | grep -v eFX-Modules`; do

### startup banner 
echo  ------------------------------------------- 
echo  building EFX module $MODULE
echo  version $VERSION 
echo  installation directory is : ${INSTALL_DIR}
echo  deployment directory is: ${DEPLOY_DIR}
echo  target environment is: ${TARGET_ENV}
echo  -------------------------------------------


### Create the directory structure required by rpmbuild 
echo creating rpmbuild directory structure under ${INSTALL_DIR}
rm -rf ${INSTALL_DIR}
mkdir ${INSTALL_DIR}
pushd ${INSTALL_DIR}
mkdir BUILD SOURCES RPMS SPECS SRPMS


###get full path to install dir
export INSTALL_DIR_PATH="$( cd "$( dirname "$0" )" && pwd )"
echo "INSTALL_DIR_PATH: $INSTALL_DIR_PATH"
popd


### Copy rpm spec and file lists in install area


### export eFX code out of SVN, based on version number passed in parameter
echo "Copying $MODULE from /home/efxbuild/eFX-Scripts/${VERSION}/SB7/" 

cp -r /home/efxbuild/eFX-Scripts/${VERSION}/SB7/${MODULE} ${INSTALL_DIR}/SOURCES

if [ "$MODULE" == "eFX-LP-UBS" ] || [ "$MODULE" == "eFX-LP-DB" ] || [ "$MODULE" == "eFX-LP-Citi" ] || [ "$MODULE" == "eFX-LP-GS" ] || [ "$MODULE" == "eFX-LP-MF" ] || [ "$MODULE" == "eFX-LP-DBFIX" ] || [ "$MODULE" == "TC_fx_handlers" ] || [ "$MODULE" == "TC_common" ] || [ "$MODULE" == "eFX-SB73-Common" ]; then
export DEPLOY_DIR=$3/EFX-lp
export MODULE=lp-${MODULE}
else
export DEPLOY_DIR=$3/EFX-all
export MODULE=all-${MODULE}
fi
cp ./filelists/all-3.0.partes.lst ${INSTALL_DIR}/BUILD/$MODULE.lst

### Build the RPM
echo  -------------------------------------------
echo  launching rpmbuild
echo  -------------------------------------------

  ## Copy rpm spec in install area
	echo "cp eFX_3_0-${MODULE}.spec ${INSTALL_DIR}/SPECS/eFX.spec"
	cp eFX_3_0-all-partes.spec ${INSTALL_DIR}/SPECS/eFX.spec
  ##rename conf folder to sample
	pushd ${INSTALL_DIR}/SPECS
	rpmbuild -bb  --define "_topdir $INSTALL_DIR_PATH" --define "deploydir $DEPLOY_DIR" --define "release $RELEASE" --define "version $VERSION" --define "module $MODULE" eFX.spec

popd


##sign the rpm
rpm --addsign ${INSTALL_DIR}/RPMS/*.rpm 

###move the rpm into the upload_area
mkdir -p /home/efxbuild/upload_area/Cerebro.${VERSION}
mv -v ${INSTALL_DIR}/RPMS/*.rpm /home/efxbuild/upload_area/Cerebro.${VERSION}


done

echo "Generado todos los paquetes excepto eFX-SB7-Common y Linux"
exit 0
fi



if [ "$4" == "eFX-SB7-Common" ]; then
export MODULE=eFX-SB7-Common
### startup banner
echo  -------------------------------------------
echo  building EFX module $MODULE
echo  version $VERSION
echo  installation directory is : ${INSTALL_DIR}
echo  deployment directory is: ${DEPLOY_DIR}
echo  target environment is: ${TARGET_ENV}
echo  -------------------------------------------


### Create the directory structure required by rpmbuild
echo creating rpmbuild directory structure under ${INSTALL_DIR}
rm -rf ${INSTALL_DIR}
mkdir ${INSTALL_DIR}
pushd ${INSTALL_DIR}
mkdir BUILD SOURCES RPMS SPECS SRPMS


###get full path to install dir
export INSTALL_DIR_PATH="$( cd "$( dirname "$0" )" && pwd )"
echo "INSTALL_DIR_PATH: $INSTALL_DIR_PATH"
popd




### export eFX code out of SVN, based on version number passed in parameter
echo "Copying $MODULE from /home/efxbuild/eFX-Scripts/${VERSION}/SB7/"

cp -r /home/efxbuild/eFX-Scripts/${VERSION}/SB7/${MODULE} ${INSTALL_DIR}/SOURCES
#copying the workaround for serializator and DB
cp -r /home/efxbuild/eFX_installer/FieldandDeutsche ${INSTALL_DIR}/SOURCES/${MODULE}

export DEPLOY_DIR=$3/EFX-all
export MODULE=all-${MODULE}

cp ./filelists/all-3.0.partes.lst ${INSTALL_DIR}/BUILD/$MODULE.lst

### Build the RPM
echo  -------------------------------------------
echo  launching rpmbuild
echo  -------------------------------------------

  ## Copy rpm spec in install area
        echo "cp eFX_3_0-all-partes-SB7-common.spec ${INSTALL_DIR}/SPECS/eFX.spec"
        cp eFX_3_0-all-partes-SB7-common.spec ${INSTALL_DIR}/SPECS/eFX.spec
  ##rename conf folder to sample
        pushd ${INSTALL_DIR}/SPECS
        rpmbuild -bb  --define "_topdir $INSTALL_DIR_PATH" --define "deploydir $DEPLOY_DIR" --define "release $RELEASE" --define "version $VERSION" --define "module $MODULE" eFX.spec

popd


##sign the rpm
rpm --addsign ${INSTALL_DIR}/RPMS/*.rpm

###move the rpm into the upload_area
mkdir -p /home/efxbuild/upload_area/Cerebro.${VERSION}
mv -v ${INSTALL_DIR}/RPMS/*.rpm /home/efxbuild/upload_area/Cerebro.${VERSION}



export MODULE=eFX-SB7-Common
### startup banner
echo  -------------------------------------------
echo  building EFX module $MODULE
echo  version $VERSION
echo  installation directory is : ${INSTALL_DIR}
echo  deployment directory is: ${DEPLOY_DIR}
echo  target environment is: ${TARGET_ENV}
echo  -------------------------------------------


### Create the directory structure required by rpmbuild
echo creating rpmbuild directory structure under ${INSTALL_DIR}
rm -rf ${INSTALL_DIR}
mkdir ${INSTALL_DIR}
pushd ${INSTALL_DIR}
mkdir BUILD SOURCES RPMS SPECS SRPMS


###get full path to install dir
export INSTALL_DIR_PATH="$( cd "$( dirname "$0" )" && pwd )"
echo "INSTALL_DIR_PATH: $INSTALL_DIR_PATH"
popd




### export eFX code out of SVN, based on version number passed in parameter
echo "Copying $MODULE from /home/efxbuild/eFX-Scripts/${VERSION}/SB7/"

cp -r /home/efxbuild/eFX-Scripts/${VERSION}/SB7/${MODULE} ${INSTALL_DIR}/SOURCES
#copying the workaround for serializator and DB
cp -r /home/efxbuild/eFX_installer/FieldandDeutsche ${INSTALL_DIR}/SOURCES/${MODULE}


export DEPLOY_DIR=$3/EFX-lp
export MODULE=lp-${MODULE}

cp ./filelists/all-3.0.partes.lst ${INSTALL_DIR}/BUILD/$MODULE.lst

### Build the RPM
echo  -------------------------------------------
echo  launching rpmbuild
echo  -------------------------------------------

  ## Copy rpm spec in install area
        echo "cp eFX_3_0-lp-partes-SB7-common.spec ${INSTALL_DIR}/SPECS/eFX.spec"
        cp eFX_3_0-lp-partes-SB7-common.spec ${INSTALL_DIR}/SPECS/eFX.spec
  ##rename conf folder to sample
        pushd ${INSTALL_DIR}/SPECS
        rpmbuild -bb  --define "_topdir $INSTALL_DIR_PATH" --define "deploydir $DEPLOY_DIR" --define "release $RELEASE" --define "version $VERSION" --define "module $MODULE" eFX.spec

popd


##sign the rpm
rpm --addsign ${INSTALL_DIR}/RPMS/*.rpm

###move the rpm into the upload_area
mkdir -p /home/efxbuild/upload_area/Cerebro.${VERSION}
mv -v ${INSTALL_DIR}/RPMS/*.rpm /home/efxbuild/upload_area/Cerebro.${VERSION}



echo "Generado eFX-SB7-Common para all y lp"
exit 0
fi

export MODULE=${4}
### startup banner
echo  -------------------------------------------
echo  building EFX module $MODULE
echo  version $VERSION
echo  installation directory is : ${INSTALL_DIR}
echo  deployment directory is: ${DEPLOY_DIR}
echo  target environment is: ${TARGET_ENV}
echo  -------------------------------------------


### Create the directory structure required by rpmbuild
echo creating rpmbuild directory structure under ${INSTALL_DIR}
rm -rf ${INSTALL_DIR}
mkdir ${INSTALL_DIR}
pushd ${INSTALL_DIR}
mkdir BUILD SOURCES RPMS SPECS SRPMS


###get full path to install dir
export INSTALL_DIR_PATH="$( cd "$( dirname "$0" )" && pwd )"
echo "INSTALL_DIR_PATH: $INSTALL_DIR_PATH"
popd




### export eFX code out of SVN, based on version number passed in parameter
echo "Copying $MODULE from /home/efxbuild/eFX-Scripts/${VERSION}/SB7/"

cp -r /home/efxbuild/eFX-Scripts/${VERSION}/SB7/${MODULE} ${INSTALL_DIR}/SOURCES

if [ "$MODULE" == "eFX-LP-UBS" ] || [ "$MODULE" == "eFX-LP-DB" ] || [ "$MODULE" == "eFX-LP-Citi" ] || [ "$MODULE" == "eFX-LP-GS" ] || [ "$MODULE" == "eFX-LP-MF" ] || [ "$MODULE" == "eFX-LP-DBFIX" ] || [ "$MODULE" == "TC_fx_handlers" ] || [ "$MODULE" == "TC_common" ] || [ "$MODULE" == "eFX-SB73-Common" ]; then
export DEPLOY_DIR=$3/EFX-lp
export MODULE=lp-${MODULE}
else
export DEPLOY_DIR=$3/EFX-all
export MODULE=all-${MODULE}
fi

cp ./filelists/all-3.0.partes.lst ${INSTALL_DIR}/BUILD/$MODULE.lst
### Build the RPM
echo  -------------------------------------------
echo  launching rpmbuild
echo  -------------------------------------------

  ## Copy rpm spec in install area
        echo "cp eFX_3_0-all-partes.spec ${INSTALL_DIR}/SPECS/eFX.spec"
        cp eFX_3_0-${MODULE}.spec ${INSTALL_DIR}/SPECS/eFX.spec
  ##rename conf folder to sample
        pushd ${INSTALL_DIR}/SPECS
        rpmbuild -bb  --define "_topdir $INSTALL_DIR_PATH" --define "deploydir $DEPLOY_DIR" --define "release $RELEASE" --define "version $VERSION" --define "module $MODULE" eFX.spec

popd


##sign the rpm
rpm --addsign ${INSTALL_DIR}/RPMS/*.rpm

###move the rpm into the upload_area
mkdir -p /home/efxbuild/upload_area/Cerebro.${VERSION}
mv -v ${INSTALL_DIR}/RPMS/*.rpm /home/efxbuild/upload_area/Cerebro.${VERSION}


echo "Generado package para ${MODULE}"
exit 0

