#!/usr/bin/env bash
set -e

export toolName='mriqc'
export toolVersion='0.16.1'
# https://github.com/poldracklab/mriqc/releases
# Don't forget to update version change in README.md!!!!!


if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug="true"
fi

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base-image poldracklab/${toolName}:$toolVersion \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir ${mountPointList}" \
   --env DEPLOY_BINS=mriqc \
   --copy README.md /README.md \
  > ${imageName}.Dockerfile

if [ "$debug" = "true" ]; then
   ./../main_build.sh
fi
