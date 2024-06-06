export toolName='quickshear'
export toolVersion='1.1.0' 

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi
source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base-image freesurfer/synthstrip:1.6 \
   --env DEBIAN_FRONTEND=noninteractive \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir -p ${mountPointList}" \
   --workdir /opt \
   --install wget git curl ca-certificates python3 python3-pip \
   --run="pip install quickshear==1.2.0" \
   --env PATH='$PATH':/opt/${toolName}-${toolVersion}/bin \
   --env DEPLOY_PATH=/opt/${toolName}-${toolVersion}/bin/ \
   --copy README.md /README.md \
   --entrypoint bash \
  > ${imageName}.${neurodocker_buildExt}
  
if [ "$1" != "" ]; then
   ./../main_build.sh
fi
