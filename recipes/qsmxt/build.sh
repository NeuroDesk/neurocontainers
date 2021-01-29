#!/usr/bin/env bash
set -e

export toolName='qsmxt'
export toolVersion='1.0.0'

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug="true"
fi

source ../main_setup.sh

# ubuntu:18.04 
# docker.pkg.github.com/neurodesk/caid/qsmxtbase_1.0.0:20210128
# vnmd/qsmxtbase_1.0.0:20210128

# this should fix the octave bug caused by fsl installing openblas:
# apt update
# apt install liblapack-dev liblas-dev
# update-alternatives --set libblas.so.3-x86_64-linux-gnu /usr/lib/x86_64-linux-gnu/blas/libblas.so.3
# update-alternatives --set liblapack.so.3-x86_64-linux-gnu /usr/lib/x86_64-linux-gnu/lapack/liblapack.so.3

neurodocker generate ${neurodocker_buildMode} \
   --base vnmd/qsmxtbase_1.0.0:20210128 \
   --pkg-manager apt \
   --run="mkdir -p ${mountPointList}" \
   --workdir /opt \
   --run="git clone https://github.com/QSMxT/QSMxT" \
   --env PATH='$PATH':/opt/bru2 \
   --env DEPLOY_PATH=/opt/minc-1.9.17/bin/:/opt/minc-1.9.17/volgenmodel-nipype/extra-scripts:/opt/minc-1.9.17/pipeline:/opt/fsl-6.0.4/bin/:/opt/freesurfer-7.1.1/bin/ \
   --env DEPLOY_BINS=dcm2niix:bidsmapper:bidscoiner:bidseditor:bidsparticipants:bidstrainer:deface:dicomsort:pydeface:rawmapper:Bru2:Bru2Nii:tgv_qsm:julia  \
   --run="cp /opt/QSMxT/README.md /README.md" \
   --install apt_opts="--quiet" liblapack-dev liblas-dev \
   --run="update-alternatives --set libblas.so.3-x86_64-linux-gnu /usr/lib/x86_64-linux-gnu/blas/libblas.so.3" \
   --run="update-alternatives --set liblapack.so.3-x86_64-linux-gnu /usr/lib/x86_64-linux-gnu/lapack/liblapack.so.3" \
  > ${imageName}.Dockerfile

if [ "$debug" = "true" ]; then
   ./../main_build.sh
fi

