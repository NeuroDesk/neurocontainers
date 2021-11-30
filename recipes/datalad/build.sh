#!/usr/bin/env bash
set -e

# this template file builds itksnap and is then used as a docker base image for layer caching
export toolName='datalad'
export toolVersion='0.15.3'
# Don't forget to update version change in README.md!!!!!

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug="true"
fi

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base-image neurodebian:sid-non-free \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir ${mountPointList}" \
   --install datalad datalad-container \
   --env DEPLOY_BINS=datalad \
   --copy README.md /README.md \
  > ${toolName}_${toolVersion}.Dockerfile

if [ "$debug" = "true" ]; then
   ./../main_build.sh
fi
