#!/usr/bin/env bash
set -e

export toolName='conn'
export toolVersion='22a'
# https://www.nitrc.org/frs/?group_id=279

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base-image ubuntu:18.04 \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir -p ${mountPointList}" \
   --matlabmcr version=2022a method=binaries \
   --workdir /opt/${toolName}-${toolVersion}/ \
   --install wget \
   --run="wget --no-check-certificate --progress=bar:force -P /opt/${toolName}-${toolVersion}/ https://www.nitrc.org/frs/download.php/13733/conn${toolVersion}_glnxa64.zip \
      && unzip -q conn${toolVersion}_glnxa64.zip -d /opt/${toolName}-${toolVersion}/ \
      && rm -f conn${toolVersion}_glnxa64.zip" \
   --env DEPLOY_BINS=${toolName} \
   --install openjdk-8-jre \
   --env PATH=/opt/${toolName}-${toolVersion}/:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
   --copy README.md /README.md \
  > ${toolName}_${toolVersion}.Dockerfile

if [ "$1" != "" ]; then
   ./../main_build.sh
fi

# 