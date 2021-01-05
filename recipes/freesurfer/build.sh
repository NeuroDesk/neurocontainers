#!/usr/bin/env bash
set -e

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug="true"
fi

export toolName='freesurfer'
export toolVersion=7.1.1

source ../main_setup.sh

# I applied for the freesurfer license for 400 users. When he hit tha many users, we need to renew the license!

neurodocker generate ${neurodocker_buildMode} \
   --base ubuntu:16.04 \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir ${mountPointList}" \
   --${toolName} version=${toolVersion} \
   --env FS_LICENSE=~/license.txt \
   --install dbus-x11 \
   --env DEPLOY_PATH=/opt/${toolName}-${toolVersion}/bin/ \
   --copy README.md /README.md \
   --user=neuro \
  > ${imageName}.${neurodocker_buildExt}

if [ "$debug" = "true" ]; then
   ./../main_build.sh
fi
