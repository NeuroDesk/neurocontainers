#!/usr/bin/env bash
set -e

# Check latest version here
# https://github.com/frankyeh/DSI-Studio/releases
export toolName='dsistudio'
export toolVersion='2020.10'

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug="true"
fi

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base dsistudio/dsistudio:latest \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir ${mountPointList}" \
   --env DEPLOY_DIR=/opt/dsi-studio/dsi_studio_64 \
   --copy README.md /README.md \
  > ${toolName}_${toolVersion}.Dockerfile

if [ "$debug" = "true" ]; then
   ./../main_build.sh
fi
