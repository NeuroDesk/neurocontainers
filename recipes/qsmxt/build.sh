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
# docker.pkg.github.com/neurodesk/caid/qsmxtbase_1.0.0:20210201
# vnmd/qsmxtbase_1.0.0:20210201


neurodocker generate ${neurodocker_buildMode} \
   --base vnmd/qsmxtbase_1.0.0:20210201 \
   --pkg-manager apt \
   --run="mkdir -p ${mountPointList}" \
   --workdir /opt \
   --run="git clone https://github.com/QSMxT/QSMxT" \
   --env PATH='$PATH':/opt/bru2 \
   --env DEPLOY_PATH=/opt/minc-1.9.17/bin/:/opt/minc-1.9.17/volgenmodel-nipype/extra-scripts:/opt/minc-1.9.17/pipeline:/opt/fsl-6.0.4/bin/:/opt/freesurfer-7.1.1/bin/ \
   --env DEPLOY_BINS=dcm2niix:bidsmapper:bidscoiner:bidseditor:bidsparticipants:bidstrainer:deface:dicomsort:pydeface:rawmapper:Bru2:Bru2Nii:tgv_qsm:julia  \
   --env PYTHONPATH=/opt/QSMxT \
   --copy qsm_tgv_main.py /TGVQSM-master-011045626121baa8bfdd6633929974c732ae35e3/TGV_QSM \
   --run="cp /opt/QSMxT/README.md /README.md" \
  > ${imageName}.Dockerfile

if [ "$debug" = "true" ]; then
   ./../main_build.sh
fi

