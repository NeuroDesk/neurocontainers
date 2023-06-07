#!/usr/bin/env bash
set -e

export toolName='fsl'
export toolVersion='6.0.6.4'

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

yes | neurodocker generate ${neurodocker_buildMode} \
   --base-image ubuntu:18.04 \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir -p ${mountPointList}" \
   --install git ca-certificates ltrace strace wget libxml2 gcc build-essential \
   --install nvidia-cuda-toolkit \
   --${toolName} version=${toolVersion} \
   --run="ln -s /opt/fsl-${toolVersion}/bin/eddy_cuda9.1 /opt/fsl-${toolVersion}/bin/eddy_cuda" \
   --env FSLOUTPUTTYPE=NIFTI_GZ \
   --install locales \
   --run="sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && locale-gen" \
   --env LANG=en_US.UTF-8 \
   --env LANGUAGE=en_US:en \
   --env LC_ALL=en_US.UTF-8 \
   --env DEPLOY_PATH=/opt/${toolName}-${toolVersion}/bin/ \
   --env DEPLOY_BINS=fsleyes:fsl \
   --env DEPLOY_ENV_FSLDIR='$CONTAINER_PATH'/opt/fsl-${toolVersion} \
   --env PATH='$PATH':/usr/local/cuda-9.1/bin \
   --env LD_LIBRARY_PATH='$LD_LIBRARY_PATH':/usr/local/cuda-9.1/lib64 \
   --copy README.md /README.md \
  > ${imageName}.${neurodocker_buildExt}

if [ "$1" != "" ]; then
   ./../main_build.sh
fi
