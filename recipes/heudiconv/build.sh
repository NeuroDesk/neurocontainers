export toolName='heudiconv'
export toolVersion='1.3.1' 
# https://hub.docker.com/r/nipy/heudiconv/tags

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh --reinstall_neurodocker=false

neurodocker generate ${neurodocker_buildMode} \
   --base-image nipy/heudiconv:$toolVersion \
   --env DEBIAN_FRONTEND=noninteractive \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir -p ${mountPointList}" \
   --env DEPLOY_BINS=heudiconv \
   --copy README.md /README.md \
   --copy test.sh /test.sh \
  > ${imageName}.${neurodocker_buildExt}
  
if [ "$1" != "" ]; then
   ./../main_build.sh
fi
