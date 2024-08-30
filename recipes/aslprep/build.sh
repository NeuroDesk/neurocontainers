#!/usr/bin/env bash
set -e

export toolName='aslprep'
export toolVersion='0.7.0'
# check if version is here: https://hub.docker.com/r/pennlinc/aslprep/tags
# Don't forget to update version change in README.md!!!!!


if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base-image pennlinc/aslprep:$toolVersion \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir -p ${mountPointList}" \
   --env DEPLOY_BINS=aslprep \
   --env HOME=~/ \
   --copy README.md /README.md \
  > ${imageName}.${neurodocker_buildExt}
   # --entrypoint bash \

if [ "$1" != "" ]; then
   ./../main_build.sh
fi
