export toolName='bidsapphcppipelines'
# toolName or toolVersion CANNOT contain capital letters or dashes or underscores (Docker registry does not accept this!)

export toolVersion='v4.3.0-3' 
# the version number cannot contain a "-" - try to use x.x.x notation always
# https://hub.docker.com/r/bids/hcppipelines/tags

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base-image bids/${toolName:7}:${toolVersion} \
   --env DEBIAN_FRONTEND=noninteractive \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir -p ${mountPointList}" \
   --env PATH='$PATH':/ \
   --env DEPLOY_PATH=/usr/local/fsl/bin:/opt/workbench/bin_linux64:/usr/local/miniconda/bin:/opt/freesurfer/bin:/opt/freesurfer/fsfast/bin:/opt/freesurfer/tktools:/opt/freesurfer/mni/bin:/ \
   --copy README.md /README.md \
   --install qt4-dev-tools libxss1 libxext6 libxft2 libjpeg62-dev libmng-dev \
  > ${imageName}.${neurodocker_buildExt}

   # --entrypoint bash \ #needs to be moved up when debugging


if [ "$1" != "" ]; then
   ./../main_build.sh
fi
