#!/usr/bin/env bash
set -e

# https://github.com/IBT-FMI/SAMRI
export toolName='samri'
export toolVersion='0.5'

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug="true"
fi

source ../main_setup.sh

   # --base docker.pkg.github.com/neurodesk/caid/fsl_6.0.3:20200905 \
neurodocker generate ${neurodocker_buildMode} \
   --base vnmd/fsl_6.0.3:20200905 \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir -p ${mountPointList}" \
   --miniconda use_env=base \
              conda_install='python=3.7 nipy nilearn traits argh joblib matplotlib numpy pandas scipy seaborn statsmodels nipype' \
              pip_install='nibabel scikit-image pybids==0.6.5 pynrrd duecredit' \
   --install git zip wget libgtk2.0-0 blender \
   --workdir /opt \
   --run="git clone https://github.com/IBT-FMI/SAMRI.git" \
   --workdir /opt/SAMRI \
   --run="python setup.py install --user" \
   --workdir /opt/bru2 \
   --run="wget https://github.com/neurolabusc/Bru2Nii/releases/download/v1.0.20180303/Bru2_Linux.zip" \
   --run="unzip Bru2_Linux.zip" \
   --env PATH='$PATH':/opt/bru2:/root/.local/bin \
   --workdir /opt \
   --ants version=2.3.4 \
   --run="git clone https://github.com/IBT-FMI/mouse-brain-atlases_generator.git" \
   --workdir /opt/mouse-brain-atlases_generator \
   --env DEPLOY_BINS=SAMRI  \
   --copy README.md /README.md \
  > ${toolName}_${toolVersion}.Dockerfile


   # --afni version=latest method=binaries install_r_pkgs='false' install_python3='false' \
   # --run="./make_archives.sh -v 0.5 -m" \
# git clone git@github.com:TheChymera/LabbookDB.git
# cd LabbookDB
# python setup.py install --user


if [ "$debug" = "true" ]; then
   ./../main_build.sh
fi
