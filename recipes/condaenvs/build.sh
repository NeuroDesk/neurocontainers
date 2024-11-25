#!/usr/bin/env bash
set -e

export toolName='condaenvs'
export toolVersion='1.0.1'
# Don't forget to update version change in README.md!!!!!

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base-image ubuntu:16.04 \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir -p ${mountPointList}" \
   --miniconda version=latest \
   --install git \
   --workdir /opt \
   --copy README.md /README.md \
   --run="git clone https://github.com/NeuroDesk/condaenvs" \
   --copy install_all.sh /opt/condaenvs/ \
   --workdir /opt/condaenvs \
   --run="bash /opt/condaenvs/install_all.sh" \
  > ${imageName}.${neurodocker_buildExt}

if [ "$1" != "" ]; then
   ./../main_build.sh
fi
