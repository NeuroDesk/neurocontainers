#!/usr/bin/env bash
set -e

export toolName='lashis'
export toolVersion=2.0
# Don't forget to update version change in README.md!!!!!

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

pip install --no-cache-dir https://github.com/NeuroDesk/neurodocker/tarball/stebo85/issue8 --upgrade

neurodocker generate ${neurodocker_buildMode} \
    --base-image neurodebian:stretch-non-free \
	--pkg-manager apt \
	--run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
	--run="chmod +x /usr/bin/ll" \
	--run="mkdir ${mountPointList}" \
	--install git libxt6 libxext6 libxtst6 libgl1-mesa-glx libc6 libice6 libsm6 libx11-6 \
	--ashs version=2.0.0 \
	--ants version=2.3.0 \
   	--copy Readme.md /README.md \
	--run="git clone https://github.com/thomshaw92/LASHiS/ /LASHiS" \
	--entrypoint /LASHiS/LASHiS.sh \
  > ${imageName}.${neurodocker_buildExt}

if [ "$1" != "" ]; then
   ./../main_build.sh
fi