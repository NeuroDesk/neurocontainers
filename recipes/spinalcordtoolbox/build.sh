#!/usr/bin/env bash
set -e

export toolName='spinalcordtoolbox'
export toolVersion='4.3'

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug="true"
fi

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base ubuntu:16.04 \
   --pkg-manager apt \
   --install="gcc libmpich-dev python3 python3-pip python3-setuptools python3-numpy python3-scipy python3-nibabel python3-matplotlib python3-h5py python3-mpi4py python3-keras python3-tqdm python3-sympy python3-requests python3-sklearn python3-skimage" \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir ${mountPointList}" \
   --run="curl -fsSL --retry 5 https://github.com/neuropoly/spinalcordtoolbox/archive/${toolVersion}.tar.gz | tar -xz -C /opt/ " \
   --workdir="/opt/${toolName}-${toolVersion}" \
   --run="pip3 install distribute2mpi nipy dipy" \
   --run="pip3 install -e ." \
   --run="sct_check_dependencies" \
   --env DEPLOY_PATH=/opt/${toolName}-${toolVersion}/bin/ \
   --user=neuro \
  > ${toolName}_${toolVersion}.Dockerfile

if [ "$debug" = "true" ]; then
   ./../main_build.sh
fi
