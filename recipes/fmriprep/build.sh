#!/usr/bin/env bash
set -e

export toolName='fmriprep'
export toolVersion='20.2.0'

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug="true"
fi

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base poldracklab/${toolName}:$toolVersion \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir ${mountPointList}" \
   --env DEPLOY_BINS=bids-validator:fmriprep \
   --copy README.md /README.md \
  > ${imageName}.Dockerfile

if [ "$debug" = "true" ]; then
   ./../main_build.sh
fi
