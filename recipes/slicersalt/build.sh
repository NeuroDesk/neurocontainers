#!/usr/bin/env bash
set -e

#https://data.kitware.com/#collection/586fbb7b8d777f05f44a5c7b/folder/5898b7ef8d777f07219fcb14
export downloadLink='https://data.kitware.com/api/v1/item/5f18b8fa9014a6d84e32ab6e/download'
export toolName='slicersalt'
export toolVersion='3.0.0'

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug="true"
fi

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base ubuntu:20.04 \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir ${mountPointList}" \
   --run="curl -fsSL --retry 5 ${downloadLink} | tar -xz -C /opt/ " \
   --install libpulse-dev libnss3 libglu1-mesa libsm6 libxrender1 libxt6 libxcomposite1 libfreetype6 libasound2 libfontconfig1 libxkbcommon0 libxcursor1 libxi6 libxrandr2 libxtst6 qt5-default libqt5svg5-dev wget libqt5opengl5-dev libqt5opengl5 libqt5gui5 libqt5core5a \
   --env DEPLOY_PATH=/opt/SlicerSALT-${toolVersion}-linux-amd64/bin \
   --env DEPLOY_BINS=SlicerSALTApp-real:SlicerSALT \
   --run="ln -s /opt/SlicerSALT-3.0.0-linux-amd64/lib/SlicerSALT-4.11/libgfortran.so /opt/SlicerSALT-3.0.0-linux-amd64/lib/SlicerSALT-4.11/libgfortran.so.3" \
   --env LD_LIBRARY_PATH=/opt/SlicerSALT-3.0.0-linux-amd64/lib/SlicerSALT-4.11:/opt/SlicerSALT-3.0.0-linux-amd64/lib/Python/lib:/opt/SlicerSALT-3.0.0-linux-amd64/lib/QtPlugins:/opt/SlicerSALT-3.0.0-linux-amd64/lib/Teem-1.12.0 \
   --env PATH=/usr/bin:/opt/SlicerSALT-${toolVersion}-linux-amd64/bin:/opt/SlicerSALT-${toolVersion}-linux-amd64 \
   --copy README.md /README.md \
  > ${toolName}_${toolVersion}.Dockerfile

if [ "$debug" = "true" ]; then
   ./../main_build.sh
fi
