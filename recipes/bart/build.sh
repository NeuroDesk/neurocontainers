#!/usr/bin/env bash
set -e

export toolName='bart'
export toolVersion='0.9.00' #https://github.com/mrirecon/bart/releases
# Don't forget to update version change in README.md!!!!!

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base-image docker.io/nvidia/cuda:12.5.1-devel-ubuntu24.04 \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir -p ${mountPointList}" \
   --install opts="--quiet" make gcc libfftw3-dev liblapacke-dev libpng-dev libopenblas-dev \
   --workdir=/opt/${toolName}-${toolVersion}/ \
   --run="curl -fsSL --retry 5 https://github.com/mrirecon/bart/archive/v${toolVersion}.tar.gz \
      | tar -xz -C /opt/${toolName}-${toolVersion}/ --strip-components 1" \
   --run="CUDA_BASE=/usr/local/cuda/ CUDA_LIB=lib64 CUDA=1 make -j 8" \
   --env TOOLBOX_PATH=/opt/${toolName}-${toolVersion}/ \
   --env PATH=/opt/${toolName}-${toolVersion}:${PATH} \
   --env DEPLOY_PATH=/opt/${toolName}-${toolVersion}/ \
   --copy README.md /README.md \
  > ${toolName}_${toolVersion}.Dockerfile

if [ "$1" != "" ]; then
   ./../main_build.sh
fi

