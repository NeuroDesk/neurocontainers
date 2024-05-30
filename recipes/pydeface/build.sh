#!/usr/bin/env bash
set -e

export toolName='pydeface'
export toolVersion='2.0.2'

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base-image vnmd/fsl_6.0.3:20200905 \
   --pkg-manager apt \
   --user root \
   --env DEBIAN_FRONTEND=noninteractive \
   --install ca-certificates \
   --miniconda version=latest \
      conda_install="python=3.7 nipype=1.5.1 nibabel=4.0.1 numpy=1.21.6" \
      pip_install="osfclient pydeface" \
   --env PATH='$PATH':/opt/pydeface/bin \
   --env DEPLOY_PATH=/opt/${toolName}-${toolVersion}/bin/:/opt/pydeface/bin \
   --copy README.md /README.md \
  > ${imageName}.${neurodocker_buildExt}

if [ "$1" != "" ]; then
   ./../main_build.sh
fi
