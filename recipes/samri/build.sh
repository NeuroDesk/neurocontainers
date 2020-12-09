#!/usr/bin/env bash
set -e

# this template file builds tools required for dicom conversion to bids
export toolName='samri'
export toolVersion='0.5'

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug="true"
fi

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base ubuntu:20.04 \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir ${mountPointList}" \
   --miniconda use_env=base \
              conda_install='python=3.7 nipy nilearn traits argh joblib matplotlib numpy pandas scipy seaborn statsmodels nipype' \
              pip_install='nibabel scikit-image pybids=0.6.5 pynrrd' \
   --install git zip wget libgtk2.0-0 blender \
   --workdir /opt \
   --run="git clone https://github.com/IBT-FMI/SAMRI.git" \
   --workdir /opt/SAMRI \
   --run="python setup.py install --user" \
   --workdir /opt/bru2 \
   --run="wget https://github.com/neurolabusc/Bru2Nii/releases/download/v1.0.20180303/Bru2_Linux.zip" \
   --run="unzip Bru2_Linux.zip" \
   --env PATH='$PATH':/opt/bru2 \
   --workdir /opt \
   --fsl version=5.0.9 \
   --ants version=2.3.4 \
   --afni version=latest method=binaries install_r_pkgs='true' install_python3='true' \
   --run="git clone https://github.com/IBT-FMI/mouse-brain-atlases_generator.git" \
   --workdir /opt/mouse-brain-atlases_generator \
   --run="./make_archives.sh -v 0.5 -m" \
   --env DEPLOY_BINS=SAMRI  \
   --copy README.md /README.md \
  > ${toolName}_${toolVersion}.Dockerfile


# git clone git@github.com:TheChymera/LabbookDB.git
# cd LabbookDB
# python setup.py install --user


if [ "$debug" = "true" ]; then
   ./../main_build.sh
fi
