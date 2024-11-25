#!/usr/bin/env bash
set -e

# this template file builds itksnap and is then used as a docker base image for layer caching
export toolName='surfice'
export toolVersion='1.0.20210730' # https://github.com/neurolabusc/surf-ice/releases 
# Don't forget to update version change in README.md!!!!!

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base-image ubuntu:20.04 \
   --env DEBIAN_FRONTEND=noninteractive \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir -p ${mountPointList}" \
   --install wget unzip ca-certificates libgtk2.0-0 libqt5pas1 appmenu-gtk2-module libglu1-mesa \
   --workdir /opt \
   --run="wget --quiet -O surfice_linux.zip 'https://github.com/neurolabusc/surf-ice/releases/download/v${toolVersion}/surfice_linux.zip' \
      && unzip surfice_linux.zip  \
      && rm -rf surfice_linux.zip" \
   --run="wget --quiet -O libqt5pas1_2.9-0_amd64.deb 'https://github.com/davidbannon/libqt5pas/releases/download/v1.2.9/libqt5pas1_2.9-0_amd64.deb' \
      && apt install ./libqt5pas1_2.9-0_amd64.deb  \
      && rm -rf libqt5pas1_2.9-0_amd64.deb" \
   --env PATH=/opt/Surf_Ice:/opt/Surf_Ice/Resources:$PATH \
   --env DEPLOY_BINS=surfice:surficeOld:surficeOld_qt5:surfice_qt5 \
   --copy README.md /README.md \
  > ${imageName}.${neurodocker_buildExt}

if [ "$1" != "" ]; then
   ./../main_build.sh
fi
