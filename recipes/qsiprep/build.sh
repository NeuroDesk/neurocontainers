#!/usr/bin/env bash
set -e

export toolName='qsiprep'
export toolVersion='0.20.0'
# check if version is here: https://hub.docker.com/r/pennbbl/qsiprep/tags
# or https://github.com/PennLINC/qsiprep/releases

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh


neurodocker generate ${neurodocker_buildMode} \
   --base-image pennbbl/${toolName}:$toolVersion \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir -p ${mountPointList}" \
   --env DEPLOY_BINS=qsiprep \
   --copy README.md /README.md \
  > ${imageName}.${neurodocker_buildExt}

if [ "$1" != "" ]; then
   ./../main_build.sh
fi
