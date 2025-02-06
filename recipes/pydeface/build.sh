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
   --run="mkdir -p ${mountPointList}" \
   --env DEBIAN_FRONTEND=noninteractive \
   --install ca-certificates \
   --miniconda version=4.6.14 \
      conda_install="python=3.7 nipype=1.5.1 nibabel=4.0.1 numpy=1.21.6" \
      pip_install="osfclient pydeface==${toolVersion}" \
   --env PATH='$PATH':/opt/pydeface/bin \
   --env DEPLOY_PATH=/opt/${toolName}-${toolVersion}/bin/:/opt/pydeface/bin \
   --copy README.md /README.md \
  > ${imageName}.${neurodocker_buildExt}

# add USER root to the Dockerfile before apt install as --user root only takes effect after the installation 
sed -i '/    ND_ENTRYPOINT="\/neurodocker\/startup.sh"/a USER root' ${toolName}_${toolVersion}.Dockerfile

if [ "$1" != "" ]; then
   ./../main_build.sh
fi
