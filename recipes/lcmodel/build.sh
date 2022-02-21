#!/usr/bin/env bash
set -e

# this template file builds itksnap and is then used as a docker base image for layer caching
export toolName='lcmodel'
export toolVersion='6.3'
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
   --run="mkdir ${mountPointList}" \
   --install="curl libxft2 libxss1 libtk8.5 libnet-ifconfig-wrapper-perl vim nano unzip gv" \
   --workdir=/opt/${toolName}-${toolVersion}/ \
   --run="curl -o /opt/lcm-64.tar http://www.lcmodel.com/pub/LCModel/programs/lcm-64.tar && \
          tar xf /opt/lcm-64.tar && \
          rm -rf /opt/lcm-64.tar" \
   --run="gunzip  -c  lcm-core.tar.gz  |  tar  xf  -" \
   --run="rm -rf lm-core.tar.gz" \
   --workdir=/opt/${toolName}-${toolVersion}/.lcmodel/basis-sets \
   --run="curl -o /opt/${toolName}-${toolVersion}/.lcmodel/basis-sets/3t.zip http://www.s-provencher.com/pub/LCModel/3t.zip && \
         unzip /opt/${toolName}-${toolVersion}/.lcmodel/basis-sets/3t.zip && \
         rm -rf /opt/${toolName}-${toolVersion}/.lcmodel/basis-sets/3t.zip" \
   --run="curl -o /opt/${toolName}-${toolVersion}/.lcmodel/basis-sets/1.5t.zip http://www.s-provencher.com/pub/LCModel/1.5t.zip && \
         unzip /opt/${toolName}-${toolVersion}/.lcmodel/basis-sets/1.5t.zip && \
         rm -rf /opt/${toolName}-${toolVersion}/.lcmodel/basis-sets/1.5t.zip" \
   --run="curl -o /opt/${toolName}-${toolVersion}/.lcmodel/basis-sets/7t.zip http://www.s-provencher.com/pub/LCModel/7t.zip && \
         unzip /opt/${toolName}-${toolVersion}/.lcmodel/basis-sets/7t.zip && \
         rm -rf /opt/${toolName}-${toolVersion}/.lcmodel/basis-sets/7t.zip" \
   --run="curl -o /opt/${toolName}-${toolVersion}/.lcmodel/basis-sets/9.4t.zip http://www.s-provencher.com/pub/LCModel/9.4t.zip && \
         unzip /opt/${toolName}-${toolVersion}/.lcmodel/basis-sets/9.4t.zip && \
         rm -rf /opt/${toolName}-${toolVersion}/.lcmodel/basis-sets/9.4t.zip" \
   --copy license  /opt/${toolName}-${toolVersion}/.lcmodel/license \
   --copy setup_lcmodel.sh  /opt/${toolName}-${toolVersion}/.lcmodel/bin \
   --workdir /opt/${toolName}-${toolVersion}/.lcmodel/profiles/1/control-defaults \
   --copy controlfiledefault  /opt/${toolName}-${toolVersion}/.lcmodel/profiles/1/control-defaults/ \
   --run="chmod a+rwx /opt/${toolName}-${toolVersion} -R" \
   --env DEPLOY_PATH=/opt/${toolName}-${toolVersion}/.lcmodel/bin/:/opt/${toolName}-${toolVersion}/.lcmodel/ \
   --env PATH=/opt/${toolName}-${toolVersion}/.lcmodel/bin/:/opt/${toolName}-${toolVersion}/.lcmodel/:'$PATH' \
   --copy README.md /README.md \
  > ${imageName}.${neurodocker_buildExt}

if [ "$1" != "" ]; then
   ./../main_build.sh
fi
   # --run="./install-lcmodel" \
