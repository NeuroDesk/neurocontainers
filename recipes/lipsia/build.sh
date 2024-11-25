export toolName='lipsia'
export toolVersion='3.1.1' 

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi
source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base-image ubuntu:18.04 \
   --env DEBIAN_FRONTEND=noninteractive \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir -p ${mountPointList}" \
   --workdir /opt \
   --install wget git curl ca-certificates unzip build-essential libgsl0-dev libboost-dev zlib1g-dev git lsb-release libopenblas-dev \
   --run="git clone --depth 1 --branch ${toolVersion} https://github.com/lipsia-fmri/lipsia.git \
    	&& cd lipsia && bash -c \"source lipsia-setup.sh && cd src && make\"" \
   --env PATH='$PATH':/opt/${toolName}/bin \
   --env LD_LIBRARY_PATH='$LD_LIBRARY_PATH':/opt/${toolName}/lib \
   --env DEPLOY_PATH=/opt/${toolName}/bin/ \
   --copy README.md /README.md \
  > ${imageName}.${neurodocker_buildExt}
  

if [ "$1" != "" ]; then
   ./../main_build.sh
fi
