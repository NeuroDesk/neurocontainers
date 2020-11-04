#!/usr/bin/env bash
set -e

export toolName='mrtrix3'
export toolVersion='3.0.1'

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base docker.pkg.github.com/neurodesk/caid/fsl_6.0.3:20200905 \
   --pkg-manager apt \
   --${toolName} version=${toolVersion} method="source" \
   --ants version="2.3.4" \
   --install dbus-x11 \
   --env DEPLOY_PATH=/opt/${toolName}-${toolVersion}/bin/ \
   --user=neuro \
  > ${imageName}.Dockerfile
