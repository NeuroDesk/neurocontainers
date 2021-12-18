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
   --base-image centos:7 \
   --env DEBIAN_FRONTEND=noninteractive \
   --pkg-manager yum \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir ${mountPointList}" \
   --install wget unzip ca-certificates gtk2 mesa-dri-drivers \
   --workdir /opt \
   --run="wget --quiet -O MRIcroGL_linux.zip 'https://github.com/rordenlab/MRIcroGL/releases/download/v${toolVersion}/MRIcroGL_linux.zip' \
      && unzip MRIcroGL_linux.zip  \
      && rm -rf MRIcroGL_linux.zip" \
   --env PATH=/opt/MRIcroGL:/opt/MRIcroGL/Resources:$PATH \
   --env DEPLOY_BINS=MRIcroGL:dcm2niix \
   --copy README.md /README.md \
  > ${imageName}.${neurodocker_buildExt}
   # --miniconda version=latest \
   #          conda_install='python=3.7' \
   #          pip_install='gl' \

if [ "$1" != "" ]; then
   ./../main_build.sh
fi
