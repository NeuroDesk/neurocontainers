export toolName='hcppipelines'
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
   --base-image bids/${toolName}:${toolVersion} \
   --env DEBIAN_FRONTEND=noninteractive \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir -p ${mountPointList}" \
   --env DEPLOY_PATH=/opt/${toolName}-${toolVersion}/bin/ \
   --copy README.md /README.md \
  > ${imageName}.${neurodocker_buildExt}
  
if [ "$1" != "" ]; then
   ./../main_build.sh
fi
