#!/usr/bin/env bash
set -e

# this template file builds itksnap and is then used as a docker base image for layer caching
export toolName='mricrogl'
export toolVersion='1.2.20211006' # https://github.com/rordenlab/MRIcroGL 
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
   --install wget unzip ca-certificates libgtk2.0-0 libqt5pas1 appmenu-gtk2-module libglu1-mesa pigz \
   --workdir /opt \
   --run="wget --quiet -O MRIcroGL_linux_includes_Python.zip 'https://github.com/rordenlab/MRIcroGL/releases/download/v${toolVersion}/MRIcroGL_linux_includes_Python.zip' \
      && unzip MRIcroGL_linux_includes_Python.zip  \
      && rm -rf MRIcroGL_linux_includes_Python.zip" \
   --run="wget --quiet -O libqt5pas1_2.9-0_amd64.deb 'https://github.com/davidbannon/libqt5pas/releases/download/v1.2.9/libqt5pas1_2.9-0_amd64.deb' \
      && apt install ./libqt5pas1_2.9-0_amd64.deb  \
      && rm -rf libqt5pas1_2.9-0_amd64.deb" \
   --env PATH=/opt/MRIcroGL:/opt/MRIcroGL/Resources:$PATH \
   --env DEPLOY_BINS=MRIcroGL:dcm2niix \
   --copy README.md /README.md \
  > ${imageName}.${neurodocker_buildExt}

   # --miniconda version=4.7.12.1 \
   #          conda_install='python=3.6' \

# explanation for miniconda version: this is the last version where python 3.6 doesn't create a conflict when installing

if [ "$1" != "" ]; then
   ./../main_build.sh
fi
