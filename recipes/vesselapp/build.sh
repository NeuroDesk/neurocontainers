#!/usr/bin/env bash
set -e

export toolName='vesselapp'
export toolVersion='0.5.0'

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
--base-image pytorch/pytorch:1.13.1-cuda11.6-cudnn8-runtime \
--pkg-manager apt \
--env DEBIAN_FRONTEND=noninteractive \
--install git \
--workdir '/opt/' \
--run='git clone https://github.com/KMarshallX/vessel_code' \
--run='pip install matplotlib nibabel patchify scikit-learn scipy antspyx connected-components-3d' \
--copy README.md /README.md \
> ${toolName}_${toolVersion}.Dockerfile 

if [ "$1" != "" ]; then 
./../main_build.sh 
fi