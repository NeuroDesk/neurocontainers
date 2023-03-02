#!/usr/bin/env bash
set -e

export toolName='minc'
export toolVersion=1.9.18
# Don't forget to update version change in README.md!!!!!

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

# if [ "$debug" != "" ]; then
   echo "installing development repository of neurodocker:"
   yes | pip uninstall neurodocker
   pip install --no-cache-dir https://github.com/NeuroDesk/neurodocker/tarball/minc_install_from_deb_and_rpm --upgrade
   # pip install --no-cache-dir https://github.com/NeuroDesk/neurodocker/tarball/master --upgrade
# fi

neurodocker generate ${neurodocker_buildMode} \
   --base-image ubuntu:18.04 \
   --pkg-manager apt \
   --run="mkdir ${mountPointList}" \
   --copy README.md /README.md \
   --${toolName} version=${toolVersion} \
   --env DEPLOY_PATH=/opt/${toolName}-${toolVersion}/bin/:/opt/${toolName}-${toolVersion}/volgenmodel-nipype/extra-scripts:/opt/${toolName}-${toolVersion}/pipeline \
  > ${imageName}.${neurodocker_buildExt}


if [ "$1" != "" ]; then
   ./../main_build.sh
fi
