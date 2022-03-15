#!/usr/bin/env bash
set -e

# this template file builds tools required for dicom conversion to bids
export toolName='bidstools'
export toolVersion='1.0.0'
# Don't forget to update version change in README.md!!!!!

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base-image ubuntu:20.04 \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir ${mountPointList}" \
   --miniconda version=4.7.12.1 \
              conda_install='python=3.6 traits' \
              pip_install='bidscoin' \
   --dcm2niix method=source version=latest \
   --install apt_opts="--quiet" wget zip libgl1 libglib2.0 libglu1-mesa libsm6 libxrender1 libxt6 libxcomposite1 libfreetype6 libasound2 libfontconfig1 libxkbcommon0 libxcursor1 libxi6 libxrandr2 libxtst6 qt5-default libqt5svg5-dev wget libqt5opengl5-dev libqt5opengl5 libqt5gui5 libqt5core5a \
   --install libgtk2.0-0 \
   --workdir /opt/bru2 \
   --run="wget https://github.com/neurolabusc/Bru2Nii/releases/download/v1.0.20180303/Bru2_Linux.zip" \
   --run="unzip Bru2_Linux.zip" \
   --env PATH='$PATH':/opt/bru2 \
   --env DEPLOY_BINS=dcm2niix:bidsmapper:bidscoiner:bidseditor:bidsparticipants:bidstrainer:deface:dicomsort:pydeface:rawmapper:Bru2:Bru2Nii  \
   --copy README.md /README.md \
  > ${toolName}_${toolVersion}.Dockerfile

if [ "$1" != "" ]; then
   ./../main_build.sh
fi
