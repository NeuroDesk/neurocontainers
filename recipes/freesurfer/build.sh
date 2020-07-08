#!/usr/bin/env bash
set -e

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug="true"
fi

export toolName='freesurfer'
export toolVersion=7.1.0

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base ubuntu:16.04 \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir ${mountPointList}" \
   --${toolName} version=${toolVersion} \
   --env DEPLOY_PATH=/opt/${toolName}-${toolVersion}/bin/ \
   --user=neuro \
  > ${imageName}.${neurodocker_buildExt}

if [ "$debug" = "true" ]; then
   ./../main_build.sh
fi