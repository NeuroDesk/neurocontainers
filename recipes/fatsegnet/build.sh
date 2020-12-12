#!/usr/bin/env bash
set -e

# https://github.com/Deep-MI/FatSegNet
export toolName='fatsegnet'
export toolVersion='1.0.gpu'

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug="true"
fi

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base tensorflow/tensorflow:1.6.0-gpu-py3 \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir -p ${mountPointList}" \
   --install git python3-tk \
   --workdir /opt \
   --run="git clone https://github.com/Deep-MI/FatSegNet.git" \
   --workdir /opt/FatSegNet \
   --run="mv tool /tool" \
   --run="pip3 --no-cache-dir install pandas==0.21.0 scikit-learn==0.19.1 scipy==1.1. scikit-image==0.15.0 SimpleITK==1.1.0 nibabel==2.2.1 keras==2.2.4 numpy==1.15.4" \
   --workdir /tool \
   --run="bash /tool/bash_profile" \
   --copy README.md /README.md \
  > ${toolName}_${toolVersion}.Dockerfile



if [ "$debug" = "true" ]; then
   ./../main_build.sh
fi
