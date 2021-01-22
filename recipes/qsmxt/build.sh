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

neurodocker generate ${neurodocker_buildMode} \
   --base docker.pkg.github.com/neurodesk/caid/qsmxtbase_1.0.0:20210122 \
   --pkg-manager apt \
   --run="mkdir -p ${mountPointList}" \
   --workdir /opt \
   --run="conda install -c conda-forge dicomifier"
   --run="git clone https://github.com/QSMxT/QSMxT" \
   --env PATH='$PATH':/opt/bru2 \
   --env DEPLOY_BINS=recon-all:dcm2niix:bidsmapper:bidscoiner:bidseditor:bidsparticipants:bidstrainer:deface:dicomsort:pydeface:rawmapper:Bru2:Bru2Nii:tgv_qsm:fslmaths:fslstats:mnc2nii:niii2mnc:tgv_qsm:recon-all:bidsmapper:bidscoiner:bet:julia:mri_convert:bestlinreg:mincresample:volcentre:norm:volpad:voliso:math:pik:blur:gennlxfm:xfmconcat:bestlinreg:nlpfit:xfmavg:xfminvert:resample:bigaverage:reshape:volsymm  \
   --run="cp /opt/QSMxT/README.md /README.md" \
  > ${imageName}.Dockerfile

if [ "$debug" = "true" ]; then
   ./../main_build.sh
fi

