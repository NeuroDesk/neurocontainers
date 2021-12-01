#!/usr/bin/env bash
set -e

export toolName='mrtrix3'
export toolVersion='3.0.3'
# Don't forget to update version change in README.md!!!!!
# https://github.com/MRtrix3/mrtrix3/releases/

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug="true"
fi

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base-image ghcr.io/neurodesk/caid/fsl_6.0.3:20200905 \
   --pkg-manager apt \
   --${toolName} version=${toolVersion} method="source" \
   --ants version="2.3.4" \
   --install dbus-x11 less \
   --env DEPLOY_PATH=/opt/${toolName}-${toolVersion}/bin/ \
   --copy README.md /README.md \
   --user=neuro \
  > ${imageName}.Dockerfile

if [ "$debug" = "true" ]; then
   ./../main_build.sh
fi