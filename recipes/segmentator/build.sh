export toolName='segmentator'
export toolVersion='1.6.1' 
# https://github.com/ofgulban/segmentator/releases 

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi
source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base-image neurodebian:sid-non-free \
   --env DEBIAN_FRONTEND=noninteractive \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir -p ${mountPointList}" \
   --install wget git curl ca-certificates unzip python3 python3-pip \
   --workdir /opt \
   --env PATH='$PATH':/opt/${toolName}-${toolVersion}/bin \
   --env DEPLOY_PATH=/opt/${toolName}-${toolVersion}/bin/ \
   --copy README.md /README.md \
   --copy test.sh /test.sh \
  > ${imageName}.${neurodocker_buildExt}
   # --run="wget https://github.com/ofgulban/segmentator/archive/refs/tags/v1.6.1.zip | 
   # && unzip " \
  
if [ "$1" != "" ]; then
   ./../main_build.sh
fi
