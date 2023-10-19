#!/usr/bin/env bash
set -e

export toolName='conn'
export toolVersion='21a'
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
   --matlabmcr version=2021a method=binaries \
   --workdir /opt/${toolName}-${toolVersion}/ \
   --run="curl -fsSL --retry 5 https://www.nitrc.org/frs/download.php/12424/conn21a_glnxa64.zip \
      | tar -xz -C /opt/${toolName}-${toolVersion}/ --strip-components 1" \
   --env DEPLOY_BINS=${toolName} \
   --install openjdk-8-jre \
   --env PATH=/opt/${toolName}-${toolVersion}/:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
   --copy README.md /README.md \
  > ${toolName}_${toolVersion}.Dockerfile

if [ "$1" != "" ]; then
   ./../main_build.sh
fi
