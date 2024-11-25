export toolName='bidsappbrainsuite'
# toolName or toolVersion CANNOT contain capital letters or dashes or underscores (Docker registry does not accept this!)

export toolVersion='21a' 
# the version number cannot contain a "-" - try to use x.x.x notation always
# https://hub.docker.com/r/bids/brainsuite/tags

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base-image bids/${toolName:7}:v${toolVersion} \
   --env DEBIAN_FRONTEND=noninteractive \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir -p ${mountPointList}" \
   --env PATH='$PATH':/BrainSuite/ \
   --env DEPLOY_PATH=/BrainSuite/QC/:/bfp:/opt/BrainSuite21a/bin/:/opt/BrainSuite21a/svreg/bin/:/opt/BrainSuite21a/bdp/:/usr/local/miniconda/bin:/BrainSuite/ \
   --copy README.md /README.md \
   --entrypoint bash \
  > ${imageName}.${neurodocker_buildExt}

# currently this image wastes 5gb of space due to chmod commands in the upstream Dockerfile! Needs to use skipdive in the commit message to build this image and skip our waste detection.

if [ "$1" != "" ]; then
   ./../main_build.sh
fi
