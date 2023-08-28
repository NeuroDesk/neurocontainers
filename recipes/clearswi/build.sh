#!/usr/bin/env bash
set -e

export toolName='clearswi'
export toolVersion='1.0.0'
export juliaVersion='1.6.3'
# Don't forget to update version change in README.md!!!!!

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base-image ubuntu:20.04 \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir -p ${mountPointList}" \
   --install git wget ca-certificates vim \
   --workdir /opt \
   --run="wget https://julialang-s3.julialang.org/bin/linux/x64/${juliaVersion:0:3}/julia-${juliaVersion}-linux-x86_64.tar.gz" \
   --run="tar zxvf julia-${juliaVersion}-linux-x86_64.tar.gz" \
   --run="rm -rf julia-${juliaVersion}-linux-x86_64.tar.gz" \
   --env PATH='$PATH':/opt/julia-${juliaVersion}/bin \
   --copy install_packages.jl /opt \
   --env JULIA_DEPOT_PATH=/opt/julia_depot \
   --run="julia install_packages.jl" \
   --run="chmod a+rwx /opt/julia_depot/packages/CLEARSWI -R" \
   --copy README.md /README.md \
  > ${imageName}.${neurodocker_buildExt}

if [ "$1" != "" ]; then
   ./../main_build.sh
fi


   
# testing:

   # --install python3-pip zip \
   # --run="pip install osfclient" \
   # --workdir /neurodesktop-storage \
   # --run="chmod a+rwx /neurodesktop-storage" \
   # --install unzip \
   # --user neuro \
   # --run="osf -p ru43c fetch 01_bids.zip /neurodesktop-storage/swi-demo/01_bids.zip" \
   # --run="unzip /neurodesktop-storage/swi-demo/01_bids.zip -d /neurodesktop-storage/swi-demo/" \
   # --copy test.jl /neurodesktop-storage \
   # --run="julia test.jl" \