#!/usr/bin/env bash
set -e

export toolName='qsmxt'
export toolVersion='1.0.0'

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug="true"
fi

source ../main_setup.sh

#
# ubuntu:18.04 

neurodocker generate ${neurodocker_buildMode} \
   --base docker.pkg.github.com/neurodesk/caid/devbase_1.0.0:20210111 \
   --pkg-manager apt \
   --run="mkdir -p ${mountPointList}" \
   --miniconda use_env=base \
              conda_install='python=3.6 traits nipype' \
              pip_install='bidscoin' \
   --install apt_opts="--quiet" libgtk2.0-0 git graphviz wget zip libgl1 libglib2.0 libglu1-mesa libsm6 libxrender1 libxt6 libxcomposite1 libfreetype6 libasound2 libfontconfig1 libxkbcommon0 libxcursor1 libxi6 libxrandr2 libxtst6 qt5-default libqt5svg5-dev wget libqt5opengl5-dev libqt5opengl5 libqt5gui5 libqt5core5a \
   --workdir /opt \
   --run="git clone https://github.com/QSMxT/QSMxT" \
   --workdir /opt/bru2 \
   --run="wget https://github.com/neurolabusc/Bru2Nii/releases/download/v1.0.20180303/Bru2_Linux.zip" \
   --run="unzip Bru2_Linux.zip" \
   --env PATH='$PATH':/opt/bru2 \
   --env DEPLOY_BINS=dcm2niix:bidsmapper:bidscoiner:bidseditor:bidsparticipants:bidstrainer:deface:dicomsort:pydeface:rawmapper:Bru2:Bru2Nii  \
   --copy README.md /README.md \
   --env PYTHONPATH=/opt/QSMxT/ \
  > ${imageName}.Dockerfile

if [ "$debug" = "true" ]; then
   ./../main_build.sh
fi
