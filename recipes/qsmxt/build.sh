#!/usr/bin/env bash
set -e

export toolName='qsmxt'
export toolVersion='1.0.0'

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug="true"
fi

source ../main_setup.sh

# ubuntu:18.04 

neurodocker generate ${neurodocker_buildMode} \
   --base docker.pkg.github.com/neurodesk/caid/devbase_1.0.0:20210112 \
   --pkg-manager apt \
   --run="mkdir -p ${mountPointList}" \
   --itksnap version=3.8.0 \
   --workdir /opt \
   --run="git clone https://github.com/QSMxT/QSMxT" \
   --env PATH='$PATH':/opt/bru2 \
   --env DEPLOY_BINS=dcm2niix:bidsmapper:bidscoiner:bidseditor:bidsparticipants:bidstrainer:deface:dicomsort:pydeface:rawmapper:Bru2:Bru2Nii  \
   --run="cp /opt/QSMxT/README.md /README.md" \
  > ${imageName}.Dockerfile

if [ "$debug" = "true" ]; then
   ./../main_build.sh
fi

