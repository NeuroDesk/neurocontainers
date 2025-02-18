#!/usr/bin/env bash
set -e

export toolName='hcpasl'
export toolVersion='1.0.0'

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi


source ../main_setup.sh

yes | neurodocker generate ${neurodocker_buildMode} \
   --base-image ubuntu:22.04 \
   --pkg-manager apt \
   --env DEBIAN_FRONTEND=noninteractive \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir -p ${mountPointList}" \
   --install wget curl git \
   --miniconda \
      version=latest \
      conda_install="python=3.11 numpy scipy" \
      pip_install="git+https://github.com/physimals/hcp-asl.git nibabel" \
   --fsl version=6.0.5.1 \
   --freesurfer version=7.4.1 \
   --install connectome-workbench \
   --run="git clone https://github.com/Washington-University/HCPpipelines.git /opt/HCPpipelines" \
   --env CARET7DIR=/usr/local/workbench/ \
   --env HCPPIPEDIR=/opt/HCPpipelines \
   --run="mkdir -p ${mountPointList}" \
   --copy README.md /README.md \
   --workdir /opt \
   > ${imageName}.${neurodocker_buildExt}

if [ "$1" != "" ]; then
   ./../main_build.sh
fi