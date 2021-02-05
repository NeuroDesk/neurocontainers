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
# docker.pkg.github.com/neurodesk/caid/qsmxtbase_1.0.0:20210203
# vnmd/qsmxtbase_1.0.0:20210203


neurodocker generate ${neurodocker_buildMode} \
   --base vnmd/qsmxtbase_1.0.0:20210203 \
   --pkg-manager apt \
   --run="mkdir -p ${mountPointList}" \
   --workdir /opt \
   --run="wget https://julialang-s3.julialang.org/bin/linux/x64/1.5/julia-1.5.3-linux-x86_64.tar.gz" \
   --run="tar zxvf julia-1.5.3-linux-x86_64.tar.gz" \
   --run="rm -rf julia-1.5.3-linux-x86_64.tar.gz" \
   --env PATH='$PATH':/opt/julia-1.5.3/bin \
   --run="git clone https://github.com/QSMxT/QSMxT" \
   --env PATH='$PATH':/opt/bru2 \
   --env DEPLOY_PATH=/opt/minc-1.9.17/bin/:/opt/minc-1.9.17/volgenmodel-nipype/extra-scripts:/opt/minc-1.9.17/pipeline:/opt/fsl-6.0.4/bin/:/opt/freesurfer-7.1.1/bin/ \
   --env DEPLOY_BINS=dcm2niix:bidsmapper:bidscoiner:bidseditor:bidsparticipants:bidstrainer:deface:dicomsort:pydeface:rawmapper:Bru2:Bru2Nii:tgv_qsm:julia  \
   --env PYTHONPATH=/opt/QSMxT:/TGVQSM-master-011045626121baa8bfdd6633929974c732ae35e3/TGV_QSM \
   --run="cp /opt/QSMxT/README.md /README.md" \
  > ${imageName}.Dockerfile

if [ "$debug" = "true" ]; then
   ./../main_build.sh
fi

