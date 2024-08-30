export toolName='dafne'
export toolVersion='1.8a4' 

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi
source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base-image ubuntu:22.04 \
   --env DEBIAN_FRONTEND=noninteractive \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir -p ${mountPointList}" \
   --install opts="--quiet" build-essential wget git curl ca-certificates unzip libgl1 libglib2.0-0 libsm6 libxrender1 libxext6 \
   --miniconda version=py38_22.11.1-1 \
            mamba=true \
            conda_install='python=3.8 tensorflow ' \
            pip_install='pyradiomics dafne==1.8a4' \
   --env DEPLOY_BINS=dafne \
   --copy README.md /README.md \
   --copy test.sh /test.sh \
  > ${imageName}.${neurodocker_buildExt}
  
if [ "$1" != "" ]; then
   ./../main_build.sh
fi
