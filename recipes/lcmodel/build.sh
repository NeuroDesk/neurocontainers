#!/usr/bin/env bash
set -e

# this template file builds itksnap and is then used as a docker base image for layer caching
export toolName='lcmodel'
export toolVersion='6.3'

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug="true"
fi

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base ubuntu:16.04 \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir ${mountPointList}" \
   --workdir=/opt/${toolName}-${toolVersion}/ \
   --run="curl -o /opt/lcm-64.tar http://www.lcmodel.com/pub/LCModel/programs/lcm-64.tar" \
   --run="tar xf /opt/lcm-64.tar" \
   --run="gunzip  -c  lcm-core.tar.gz  |  tar  xf  -" \
   --install="libxft2 libxss1 libtk8.5 libnet-ifconfig-wrapper-perl" \
   --run="touch /opt/${toolName}-${toolVersion}/.lcmodel/license" \
   --env DEPLOY_PATH=/opt/${toolName}-${toolVersion}/.lcmodel/bin/:/opt/${toolName}-${toolVersion}/.lcmodel/ \
   --env PATH=/opt/${toolName}-${toolVersion}/.lcmodel/bin/:/opt/${toolName}-${toolVersion}/.lcmodel/:$PATH \
   --copy README.md /README.md \
  > ${toolName}_${toolVersion}.Dockerfile

if [ "$debug" = "true" ]; then
   ./../main_build.sh
fi
   # --run="./install-lcmodel" \
