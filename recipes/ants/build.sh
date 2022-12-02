#!/usr/bin/env bash
set -e

export toolName='ants'
export toolVersion='2.4.2' # https://github.com/ANTsX/ANTs/releases
# Don't forget to update version change in README.md!!!!!

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

# yes | pip uninstall neurodocker
# pip install --no-cache-dir https://github.com/NeuroDesk/neurodocker/tarball/ants-add-scripts --upgrade

neurodocker generate ${neurodocker_buildMode} \
   --base-image ubuntu:22.04 \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir ${mountPointList}" \
   --${toolName} method=source version=${toolVersion} make_opts='-j2'\
   --run="chmod a+rx /opt/${toolName}-${toolVersion} -R" \
   --env DEPLOY_PATH=/opt/ants-${toolVersion}/bin:/opt/ants-${toolVersion}/Scripts \
   --copy README.md /README.md \
  > ${imageName}.${neurodocker_buildExt}

if [ "$1" != "" ]; then
   ./../main_build.sh
fi
