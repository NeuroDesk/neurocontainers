#!/usr/bin/env bash
set -e

# this template file builds itksnap and is then used as a docker base image for layer caching
export toolName='oshyx'
export toolVersion='0.2'
export toolTag='20211130'
# Don't forget to update version change in README.md!!!!!

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base-image jerync/${toolName}_${toolVersion}:${toolTag} \
   --pkg-manager apt \
	--run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
	--run="chmod +x /usr/bin/ll" \
   --run="mkdir ${mountPointList}" \
   --env DEPLOY_PATH=/opt/ants-2.3.1/:/opt/miniconda-latest/bin/python:/opt/miniconda-latest/bin/julia \
   --env DEPLOY_BINS=python:julia  \
   --copy README.md /README.md \
  > ${imageName}.${neurodocker_buildExt}

if [ "$1" != "" ]; then
   ./../main_build.sh
fi
