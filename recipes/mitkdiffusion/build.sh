export toolName='mitkdiffusion'
export toolVersion='1.2.0' 
# http://www.mitk.org/download/diffusion/nightly/MITK-Diffusion_ubuntu-20.04_NoPython.tar.gz.html

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi
source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base-image ubuntu:20.04 \
   --env DEBIAN_FRONTEND=noninteractive \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir -p ${mountPointList}" \
   --install libgomp1 libasound2 libnss3 libqt5gui5 libxi6 wget ca-certificates libxtst6 libxcomposite1 libxdamage1 libxcursor1 \
   --workdir /opt \
   --run='wget https://www.mitk.org/download/diffusion/nightly/MITK-Diffusion_ubuntu-20.04_2023.07.20_a754b053_32d7d08a_NoPython.tar.gz \
         && tar xfz MITK-Diffusion_ubuntu-20.04_2023.07.20_a754b053_32d7d08a_NoPython.tar.gz \
         && rm -rf MITK-Diffusion_ubuntu-20.04_2023.07.20_a754b053_32d7d08a_NoPython.tar.gz' \
   --env PATH='$PATH':/opt/MITK-Diffusion-2018.09.99-linux-x86_64 \
   --env DEPLOY_PATH=/opt/MITK-Diffusion-2018.09.99-linux-x86_64 \
   --copy README.md /README.md \
  > ${imageName}.${neurodocker_buildExt}
  
  
if [ "$1" != "" ]; then
   ./../main_build.sh
fi
