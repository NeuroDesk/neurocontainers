#!/usr/bin/env bash
set -e

export toolName='aslprep'
export toolVersion='0.2.7'
# check if version is here: https://hub.docker.com/r/pennlinc/aslprep/tags
# Don't forget to update version change in README.md!!!!!


if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug="true"
fi

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base-image pennlinc/aslprep:$toolVersion \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir ${mountPointList}" \
   --env DEPLOY_BINS=aslprep \
   --copy README.md /README.md \
  > ${imageName}.Dockerfile

if [ "$debug" = "true" ]; then
   ./../main_build.sh
fi
