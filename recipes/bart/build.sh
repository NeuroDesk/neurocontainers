#!/usr/bin/env bash
set -e

# this template file builds itksnap and is then used as a docker base image for layer caching
export toolName='bart'
export toolVersion='0.7.00'
# Don't forget to update version change in README.md!!!!!

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug="true"
fi

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base-image ubuntu:20.04 \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir ${mountPointList}" \
   --install apt_opts="--quiet" make gcc libfftw3-dev liblapacke-dev libpng-dev libopenblas-dev \
   --workdir=/opt/${toolName}-${toolVersion}/ \
   --run="curl -fsSL --retry 5 https://github.com/mrirecon/bart/archive/v${toolVersion}.tar.gz \
      | tar -xz -C /opt/${toolName}-${toolVersion}/ --strip-components 1" \
   --run="make" \
   --env TOOLBOX_PATH=/opt/${toolName}-${toolVersion}/ \
   --env PATH=/opt/${toolName}-${toolVersion}:${PATH} \
   --env DEPLOY_PATH=/opt/${toolName}-${toolVersion}/ \
   --copy README.md /README.md \
  > ${toolName}_${toolVersion}.Dockerfile

if [ "$debug" = "true" ]; then
   ./../main_build.sh
fi


#   --miniconda use_env=base \
   #       conda_install='python=3.6 numpy h5py matplotlib' \
   #       pip_install='bash_kernel ipykernel' \
   # --run="python -m bash_kernel.install" \