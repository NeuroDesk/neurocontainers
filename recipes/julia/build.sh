#!/usr/bin/env bash
set -e

export toolName='julia'
export toolVersion='1.6.1'
# Don't forget to update version change in README.md!!!!!

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base-image ubuntu:20.04 \
   --pkg-manager apt \
   --run="mkdir -p ${mountPointList}" \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --install zlib1g-dev libzstd1 wget \
   --workdir /opt \
   --run="wget https://julialang-s3.julialang.org/bin/linux/x64/${toolVersion:0:3}/julia-${toolVersion}-linux-x86_64.tar.gz" \
   --run="tar zxvf julia-${toolVersion}-linux-x86_64.tar.gz" \
   --run="rm -rf julia-${toolVersion}-linux-x86_64.tar.gz" \
   --env PATH='$PATH':/opt/julia-${toolVersion}/bin \
   --run="julia -e 'using Pkg; Pkg.add(\"MriResearchTools\")'" \
   --env DEPLOY_BINS=julia \
   --entrypoint /opt/julia-${toolVersion}/bin \
   --copy README.md /README.md \
  > ${imageName}.${neurodocker_buildExt}

if [ "$1" != "" ]; then
   ./../main_build.sh
fi