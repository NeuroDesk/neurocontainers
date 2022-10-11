#!/usr/bin/env bash
set -e

export toolName='fsl'
export toolVersion='6.0.5.1'
# Don't forget to update version change in README.md!!!!!

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
   --run="mkdir ${mountPointList}" \
   --install ca-certificates ltrace strace wget libxml2 gcc build-essential \
   --install nvidia-cuda-toolkit \
   --${toolName} version=${toolVersion} \
   --run="ln -s /opt/fsl-6.0.5.1/bin/eddy_cuda9.1 /opt/fsl-6.0.5.1/bin/eddy_cuda" \
   --env FSLOUTPUTTYPE=NIFTI_GZ \
   --env DEPLOY_PATH=/opt/${toolName}-${toolVersion}/bin/ \
   --env DEPLOY_BINS=fsleyes:fsl \
   --env PATH='$PATH':/usr/local/cuda-9.1/bin \
   --env LD_LIBRARY_PATH='$LD_LIBRARY_PATH':/usr/local/cuda-9.1/lib64 \
   --copy README.md /README.md \
  > ${imageName}.${neurodocker_buildExt}

if [ "$1" != "" ]; then
   ./../main_build.sh
fi
