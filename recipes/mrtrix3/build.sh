#!/usr/bin/env bash
set -e

export toolName='mrtrix3'
export toolVersion='3.0.2'
# Don't forget to update version change in README.md!!!!!
# https://github.com/MRtrix3/mrtrix3/releases/

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

export NUMBER_OF_PROCESSORS=1

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base-image vnmd/fsl_6.0.5.1:20221016 \
   --pkg-manager apt \
   --${toolName} version=${toolVersion} method="source" \
   --ants version="2.3.4" \
   --install dbus-x11 less \
   --env DEPLOY_PATH=/opt/${toolName}-${toolVersion}/bin/ \
   --copy README.md /README.md \
   --user=neuro \
  > ${imageName}.${neurodocker_buildExt}

if [ "$1" != "" ]; then
   ./../main_build.sh
fi