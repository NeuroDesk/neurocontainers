#!/usr/bin/env bash
set -e

# https://slicer.kitware.com/midas3/folder/274
# export downloadLink='https://slicer.kitware.com/midas3/download/item/549121/Slicer-4.11.20200930-linux-amd64.tar.gz'
export downloadLink='https://slicer.kitware.com/midas3/download?bitstream=1341035'
export toolName='slicer'
export toolVersion='4.11.20200930'
# Don't forget to update version change in README.md!!!!!

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug="true"
fi

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base-image ubuntu:20.04 \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir ${mountPointList}" \
   --run="curl -fsSL --retry 5 ${downloadLink} | tar -xz -C /opt/ " \
   --install libpulse-dev libnss3 libglu1-mesa libsm6 libxrender1 libxt6 libxcomposite1 libfreetype6 libasound2 libfontconfig1 libxkbcommon0 libxcursor1 libxi6 libxrandr2 libxtst6 qt5-default libqt5svg5-dev wget libqt5opengl5-dev libqt5opengl5 libqt5gui5 libqt5core5a \
   --env DEPLOY_PATH=/opt/Slicer-${toolVersion}-linux-amd64/bin \
   --env DEPLOY_BINS=Slicer \
   --env PATH=/usr/bin:/opt/Slicer-${toolVersion}-linux-amd64/bin:/opt/Slicer-${toolVersion}-linux-amd64 \
   --copy README.md /README.md \
  > ${toolName}_${toolVersion}.Dockerfile

if [ "$debug" = "true" ]; then
   ./../main_build.sh
fi
