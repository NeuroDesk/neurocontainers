#!/usr/bin/env bash
set -e
export toolName='dsistudio'
export toolVersion='2024.06.12'
# Check latest version here - replace dashes with dots
# https://hub.docker.com/r/dsistudio/dsistudio/tags


if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi
 
source ../main_setup.sh

dockerHubName=`echo $toolVersion | tr '.' '-'`

neurodocker generate ${neurodocker_buildMode} \
    --base-image ubuntu:22.04 \
    --pkg-manager apt \
    --env DEBIAN_FRONTEND=noninteractive \
    --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
    --run="chmod +x /usr/bin/ll" \
    --run="mkdir -p ${mountPointList}" \
    --install opts=--quiet wget unzip libqt6charts6-dev libglu1-mesa \
    --workdir /opt \
    --run="wget https://github.com/frankyeh/DSI-Studio/releases/download/${toolVersion}/dsi_studio_ubuntu2204.zip \
            && unzip dsi_studio_ubuntu2204.zip \
            && rm dsi_studio_ubuntu2204.zip" \
    --env QT_QPA_PLATFORM=xcb \
    --env PATH='$PATH':/opt/dsi-studio \
    --env DEPLOY_BINS=dsi_studio \
    --copy README.md /README.md \
    > ${toolName}_${toolVersion}.Dockerfile 

if [ "$1" != "" ]; then 
./../main_build.sh 
fi

# Troubleshoot QT problems:
# export QT_DEBUG_PLUGINS=1