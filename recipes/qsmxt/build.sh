#!/usr/bin/env bash
set -e

export toolName='qsmxt'
export toolVersion='1.1.8'
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
   --base-image vnmd/qsmxtbase_1.1.1:20211216 \
   --pkg-manager apt \
   --run="mkdir -p ${mountPointList}" \
   --workdir /opt \
   --run="git clone --depth 1 --branch v${toolVersion} https://github.com/QSMxT/QSMxT" \
   --run="pip install niflow-nipype1-workflows" \
   --copy install_packages.jl /opt \
   --env JULIA_DEPOT_PATH="/opt/julia_depot" \
   --run="julia install_packages.jl" \
   --env JULIA_DEPOT_PATH="~/.julia:/opt/julia_depot" \
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

# Explanation for Julia hack:
   # --env JULIA_DEPOT_PATH="/opt/julia_depot" \
   # --run="julia install_packages.jl" \
   # --env JULIA_DEPOT_PATH="~/.julia:/opt/julia_depot" \

   # The problem is that Julia packages install by default in the homedirectory
   # in singularity this homedirectory does not exist later on
   # so we have to set the Julia depot path to a path that's available in the image later
   # but: Julia assumes that this path is writable :( because it stores precompiled outputs there
   # solution is to to add a writable path before the unwritable path
   # behaviour: julia writes precompiled stuff to ~/.julia and searches for packages in both, but can't find them in ~/.julia and then searches in /opt/
   # if anyone has a better way of doing this, please let me know: @sbollmann_MRI (Twitter)