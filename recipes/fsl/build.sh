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
   --install ca-certificates ltrace strace wget libxml2 gcc \
   --run="wget https://developer.download.nvidia.com/compute/cuda/10.2/Prod/local_installers/cuda_10.2.89_440.33.01_linux.run && \
            sh cuda_10.2.89_440.33.01_linux.run --silent && \
            rm cuda_10.2.89_440.33.01_linux.run && \
            wget https://developer.download.nvidia.com/compute/cuda/10.2/Prod/patches/1/cuda_10.2.1_linux.run && \
            sh cuda_10.2.1_linux.run --silent && \
            rm cuda_10.2.1_linux.run && \
            wget https://developer.download.nvidia.com/compute/cuda/10.2/Prod/patches/2/cuda_10.2.2_linux.run && \
            sh cuda_10.2.2_linux.run --silent && \
            rm cuda_10.2.2_linux.run" \
   --${toolName} version=${toolVersion} \
   --env FSLOUTPUTTYPE=NIFTI_GZ \
   --env DEPLOY_PATH=/opt/${toolName}-${toolVersion}/bin/ \
   --env DEPLOY_BINS=fsleyes:fsl \
   --env PATH='$PATH':/usr/local/cuda-10.2/bin \
   --env LD_LIBRARY_PATH='$LD_LIBRARY_PATH':/usr/local/cuda-10.2/lib64 \
   --copy README.md /README.md \
  > ${imageName}.${neurodocker_buildExt}


# 
# 


   # --install ca-certificates wget python \
   # --workdir /opt \
   # --copy fslinstaller.py /opt \
   # --run="wget https://fsl.fmrib.ox.ac.uk/fsldownloads/fslinstaller.py" \
   # --run="opt/${toolName}-${toolVersion}/etc/fslconf/fslpython_install.sh" \

if [ "$1" != "" ]; then
   ./../main_build.sh
fi
