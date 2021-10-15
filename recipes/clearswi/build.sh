#!/usr/bin/env bash
set -e

export toolName='clearswi'
export toolVersion='1.0.0'
export juliaVersion='1.6.3'
# Don't forget to update version change in README.md!!!!!

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug="true"
fi

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base-image ubuntu:20.04 \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir ${mountPointList}" \
   --install git wget ca-certificates \
   --workdir /opt \
   --run="wget https://julialang-s3.julialang.org/bin/linux/x64/${juliaVersion:0:3}/julia-${juliaVersion}-linux-x86_64.tar.gz" \
   --run="tar zxvf julia-${juliaVersion}-linux-x86_64.tar.gz" \
   --run="rm -rf julia-${juliaVersion}-linux-x86_64.tar.gz" \
   --env PATH='$PATH':/opt/julia-${juliaVersion}/bin \
   --copy install_packages.jl /opt \
   --user neuro \
   --run="julia install_packages.jl" \
   --copy README.md /README.md \
  > ${imageName}.${neurodocker_buildExt}

if [ "$debug" = "true" ]; then
   ./../main_build.sh
fi


   
