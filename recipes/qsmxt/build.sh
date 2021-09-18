#!/usr/bin/env bash
set -e

export toolName='qsmxt'
export toolVersion='1.1.6'
# Don't forget to update version change in README.md!!!!!

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug="true"
fi

source ../main_setup.sh

# ubuntu:18.04 
# ghcr.io/neurodesk/caid/qsmxtbase_1.1.0:20210512
# vnmd/qsmxtbase_1.0.0:20210203

neurodocker generate ${neurodocker_buildMode} \
   --base-image docker.pkg.github.com/neurodesk/caid/qsmxtbase_1.1.0:20210518 \
   --pkg-manager apt \
   --run="mkdir -p ${mountPointList}" \
   --workdir /opt \
   --run="git clone --depth 1 --branch v${toolVersion} https://github.com/QSMxT/QSMxT" \
   --run="pip install niflow-nipype1-workflows" \
   --run="julia -e 'using Pkg; Pkg.add(\"ArgParse\")'" \
   --env PATH='$PATH':/opt/bru2 \
   --env PATH='$PATH':/opt/FastSurfer \
   --env DEPLOY_PATH=/opt/fsl-6.0.4/bin/:/opt/ants-2.3.4/:/opt/FastSurfer \
   --env DEPLOY_BINS=dcm2niix:bidsmapper:bidscoiner:bidseditor:bidsparticipants:bidstrainer:deface:dicomsort:pydeface:rawmapper:Bru2:Bru2Nii:tgv_qsm:julia  \
   --env PYTHONPATH=/opt/QSMxT:/TGVQSM-master-011045626121baa8bfdd6633929974c732ae35e3/TGV_QSM \
   --run="cp /opt/QSMxT/README.md /README.md" \
  > ${imageName}.Dockerfile

if [ "$debug" = "true" ]; then
   ./../main_build.sh
fi

#seems to cause problems with singularity conversion?
   # --run="sed -i '/PS1=/c\PS1=\"${toolName}_${toolVersion}:\\\w # \"' /etc/bash.bashrc" \
   # --run="sed -i '/PS1=/c\PS1=\"${toolName}_${toolVersion}:\\\w # \"' /root/.bashrc" \
   # /opt/FastSurfer/run_fastsurfer.sh