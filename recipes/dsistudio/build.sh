#!/usr/bin/env bash
set -e
export toolName='dsistudio'
export toolVersion='2024.04'
 
if [ "$1" != "" ]; then
echo "Entering Debug mode"
export debug=$1
fi
 
source ../main_setup.sh
 
neurodocker generate ${neurodocker_buildMode} \
--base-image ubuntu:22.04 \
--pkg-manager apt \
--env DEBIAN_FRONTEND=noninteractive \
--run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
--run="chmod +x /usr/bin/ll \
--run="mkdir -p ${mountPointList}" \
--install opts=--quiet  \
--run='wget https://github.com/frankyeh/DSI-Studio/releases/download/2023.12.06/dsi_studio_ubuntu2204.zip' \
--run='unzip dsi_studio_ubuntu2204.zip' \
--run='rm dsi_studio_ubuntu2204.zip ' \
--copy README.md /README.md \
> ${toolName}_${toolVersion}.Dockerfile 
if [ "$1" != "" ]; then 
./../main_build.sh 
fi
