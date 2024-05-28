#!/usr/bin/env bash
set -e
export toolName='dsistudio'
export toolVersion='chen.2024.04.19'
# Check latest version here - replace dashes with dots
# https://hub.docker.com/r/dsistudio/dsistudio/tags


if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi
 
source ../main_setup.sh

dockerHubName=`echo $toolVersion | tr '.' '-'`

neurodocker generate ${neurodocker_buildMode} \
    --base-image dsistudio/dsistudio:$dockerHubName \
    --pkg-manager apt \
    --env DEBIAN_FRONTEND=noninteractive \
    --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
    --run="chmod +x /usr/bin/ll" \
    --run="mkdir -p ${mountPointList}" \
    --env DEPLOY_BINS=dsi_studio \
    --copy README.md /README.md \
    > ${toolName}_${toolVersion}.Dockerfile 

if [ "$1" != "" ]; then 
./../main_build.sh 
fi
