#!/usr/bin/env bash
set -e

# this template file builds itksnap and is then used as a docker base image for layer caching
export toolName='mricron'
export toolVersion='1.0.20190902' #https://github.com/neurolabusc/MRIcron 
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
   --run="mkdir ${mountPointList}" \
   --install wget unzip ca-certificates  \
   --workdir /opt \
   --run="wget --quiet -O MRIcon_linux.zip 'https://github.com/neurolabusc/MRIcron/releases/download/v${toolVersion}/MRIcron_linux.zip' \
      && unzip MRIcon_linux.zip  \
      && rm -rf MRIcon_linux.zip" \
   --env PATH=/opt/MRIcron:/opt/MRIcron/Resources:$PATH \
   --env DEPLOY_BINS=MRIcron:dcm2niix \
   --copy README.md /README.md \
  > ${imageName}.${neurodocker_buildExt}

if [ "$1" != "" ]; then
   ./../main_build.sh
fi
