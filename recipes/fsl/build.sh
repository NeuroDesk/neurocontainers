#!/usr/bin/env bash
set -e

export toolName='fsl'
export toolVersion='6.0.5.1'
# Don't forget to update version change in README.md!!!!!

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

yes | pip uninstall neurodocker
pip install --no-cache-dir https://github.com/NeuroDesk/neurodocker/tarball/update-fsl-to-6.0.5.1 --upgrade

yes | neurodocker generate ${neurodocker_buildMode} \
   --base-image ubuntu:16.04 \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir ${mountPointList}" \
   --${toolName} version=${toolVersion} \
   --env FSLOUTPUTTYPE=NIFTI_GZ \
   --env DEPLOY_PATH=/opt/${toolName}-${toolVersion}/bin/ \
   --env DEPLOY_BINS=fsleyes:fsl \
   --copy README.md /README.md \
  > ${imageName}.${neurodocker_buildExt}

   # --install ca-certificates wget python \
   # --workdir /opt \
   # --copy fslinstaller.py /opt \
   # --run="wget https://fsl.fmrib.ox.ac.uk/fsldownloads/fslinstaller.py" \
   # --run="opt/${toolName}-${toolVersion}/etc/fslconf/fslpython_install.sh" \

if [ "$1" != "" ]; then
   ./../main_build.sh
fi