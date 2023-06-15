export toolName='bidsappmrtrix3connectome'
# toolName or toolVersion CANNOT contain capital letters or dashes or underscores (Docker registry does not accept this!)

export toolVersion='0.5.3' 
# the version number cannot contain a "-" - try to use x.x.x notation always
# https://hub.docker.com/r/bids/mrtrix3_connectome/tags

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base-image bids/mrtrix3_connectome:${toolVersion} \
   --env DEBIAN_FRONTEND=noninteractive \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir -p ${mountPointList}" \
   --env PATH='$PATH':/ \
   --env DEPLOY_PATH=/opt/mrtrix3/bin:/usr/lib/ants:/opt/freesurfer/bin:/opt/freesurfer/mni/bin:/opt/fsl/bin:/opt/ROBEX:/ \
   --copy README.md /README.md \
   --entrypoint bash \
  > ${imageName}.${neurodocker_buildExt}


if [ "$1" != "" ]; then
   ./../main_build.sh
fi
