#!/usr/bin/env bash
set -e

export toolName='mrtrix3workshop'
export toolVersion='0.1'

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

export deployPath=/opt/${toolName}-${toolVersion}

neurodocker generate ${neurodocker_buildMode} \
   --base-image vnmd/mrtrix3_3.0.4 \
   --pkg-manager apt \
   --workdir ${deployPath}/dwifslpreproc/DICOM \
   --run "curl https://osf.io/2mzbn/download \
         && curl https://osf.io/razk2/download \
         && curl https://osf.io/qx29y/download \
         && cat DICOM_dwifslpreproc-*.tar | tar -xi \
         && rm -f DICOM_dwifslpreproc-*.tar" \
   --env DEPLOY_PATH=${deployPath} \
   --copy README.md /README.md \
   --user=neuro \
  > ${imageName}.${neurodocker_buildExt}

# TODO Construct OverlayFS at /data to mount /opt/${toolName}-${toolVersion}/ as read-only

if [ "$1" != "" ]; then
   ./../main_build.sh
fi
