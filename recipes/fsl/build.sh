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
   --base-image ubuntu:20.04 \
   --pkg-manager apt \
   --env DEBIAN_FRONTEND=noninteractive \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir -p ${mountPointList}" \
   --install git ca-certificates ltrace strace wget libxml2 gcc build-essential \
   --install nvidia-cuda-toolkit \
   --${toolName} version=${toolVersion} \
   --env FSLOUTPUTTYPE=NIFTI_GZ \
   --install locales \
   --run="sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && locale-gen" \
   --env LANG=en_US.UTF-8 \
   --env LANGUAGE=en_US:en \
   --env LC_ALL=en_US.UTF-8 \
   --env DEPLOY_PATH=/opt/${toolName}-${toolVersion}/bin/ \
   --env DEPLOY_BINS=fsleyes:fsl \
   --env DEPLOY_ENV_FSLDIR=BASEPATH/opt/fsl-${toolVersion} \
   --run="cp /opt/fsl-6.0.6.4/bin/eddy_cuda10.2 /opt/fsl-6.0.6.4/bin/eddy_cuda" \
   --copy README.md /README.md \
  > ${imageName}.${neurodocker_buildExt}

if [ "$1" != "" ]; then
   ./../main_build.sh
fi

#CUDA SETUP
#FSL 6.0.6.4 only brings eddy_cuda10.2 -> so Ubuntu 20.04 could work because it brings nvidia-cuda-toolkit_10.1.243-3_amd64.deb or 22.04 with nvidia-cuda-toolkit_11.5.1-1ubuntu1_amd64.deb