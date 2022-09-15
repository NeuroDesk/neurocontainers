
#!/usr/bin/env bash

#Micapipe neurodocker file taken from https://github.com/MICA-MNI/micapipe/blob/master/generate_micapipe_images.sh 
#and edited to fit neurodesk

set -e

export toolName='micapipe'
export toolVersion='v0.1.2'
# Don't forget to update version change in README.md!!!!!

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

# Generate Dockerfile.
neurodocker generate ${neurodocker_buildMode} \
   --base-image micalab/${toolName}:${toolVersion} \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir ${mountPointList}" \
   --copy README.md /README.md \
  > ${imageName}.${neurodocker_buildExt}
  
  

if [ "$1" != "" ]; then
   ./../main_build.sh
fi
