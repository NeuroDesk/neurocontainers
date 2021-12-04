#!/usr/bin/env bash
set -e

export toolName='ants'
export toolVersion='2.3.1'
# Don't forget to update version change in README.md!!!!!

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug="true"
fi

if [ "$1" == "dev" ]; then
    echo "Entering development mode"
    export dev="true"
fi

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base-image ubuntu:16.04 \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir ${mountPointList}" \
   --${toolName} version=${toolVersion} \
   --run="chmod a+rx /opt/${toolName}-${toolVersion} -R" \
   --env DEPLOY_PATH=/opt/ants-${toolVersion}/ \
   --copy README.md /README.md \
  > ${imageName}.${neurodocker_buildExt}

if [ "$debug" = "true" ]; then
   ./../main_build.sh
fi
