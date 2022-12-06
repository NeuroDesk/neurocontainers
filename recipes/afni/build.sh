#!/usr/bin/env bash
set -e

#https://afni.nimh.nih.gov/pub/dist/doc/htmldoc/background_install/install_instructs/steps_linux_ubuntu20.html#install-prerequisite-packages
#https://afni.nimh.nih.gov/pub/dist/doc/htmldoc/background_install/install_instructs/steps_linux_Fed_RH.html

export toolName='afni'
export toolVersion=`wget -O- https://afni.nimh.nih.gov/pub/dist/AFNI.version | head -n 1 | cut -d '_' -f 2`
echo $toolVersion
# Afni version 22.1.14
# Don't forget to update version change in README.md!!!!!


if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

# if [ "$debug" != "" ]; then
   echo "installing development repository of neurodocker:"
   yes | pip uninstall neurodocker
   pip install --no-cache-dir https://github.com/NeuroDesk/neurodocker/tarball/fix-afni-recipe-spaces-python-R-packages  --upgrade
# fi


neurodocker generate ${neurodocker_buildMode} \
   --base-image vnmd/freesurfer_7.3.2:20220812 \
   --pkg-manager yum \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir ${mountPointList}" \
   --afni version=latest method=binaries install_r_pkgs='true' install_python3='true' \
   --env DEPLOY_PATH=/opt/${toolName}-latest/ \
   --copy README.md /README.md \
   --copy test.sh /test.sh \
  > ${imageName}.${neurodocker_buildExt}

if [ "$1" != "" ]; then
   ./../main_build.sh
fi
