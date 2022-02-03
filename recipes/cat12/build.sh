#!/usr/bin/env bash
set -e

# this template file builds cat12, new versions here: http://141.35.69.218/cat12/?C=M;O=D
export toolName='cat12'
export toolVersion='r1933'
# Don't forget to update version change in README.md!!!!!

# inspired by: https://github.com/m-wierzba/cat-container/blob/master/Singularity
# discussed here: https://github.com/ReproNim/neurodocker/issues/407

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

# once this is working contribute this to neurodocker project:
yes | pip uninstall neurodocker
pip install --no-cache-dir https://github.com/NeuroDesk/neurodocker/tarball/add-cat12 --upgrade

export MATLAB_VERSION=R2017b
export MCR_VERSION=v93
export MCR_UPDATE=9
export CAT_VERSION=12.8
export CAT_REVISION=$toolVersion

neurodocker generate ${neurodocker_buildMode} \
   --base-image ubuntu:16.04 \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir ${mountPointList}" \
   --matlabmcr version=2017b install_path=/opt/mcr  \
   --cat12 version=r1933_R2017b install_path=/opt/cat12 \
   --miniconda \
         version=latest \
         conda_install='python=3.8 traits nipype numpy scipy h5py scikit-image' \
         pip_install='osfclient' \
   --env DEPLOY_BINS=run_spm12.sh:spm12 \
   --copy README.md /README.md \
  > ${toolName}_${toolVersion}.${neurodocker_buildExt}


if [ "$1" != "" ]; then
   ./../main_build.sh
fi


# TESTS:
