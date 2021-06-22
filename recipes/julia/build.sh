#!/usr/bin/env bash
set -e

export toolName='julia'
export toolVersion='1.5.3'

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base ubuntu:20.04 \
   --pkg-manager apt \
   --run="mkdir ${mountPointList}" \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --install zlib1g-dev libzstd1 wget \
   --workdir /opt \
   --run="wget https://julialang-s3.julialang.org/bin/linux/x64/1.5/julia-${toolVersion}-linux-x86_64.tar.gz" \
   --run="tar zxvf julia-${toolVersion}-linux-x86_64.tar.gz" \
   --run="rm -rf julia-${toolVersion}-linux-x86_64.tar.gz" \
   --env PATH='$PATH':/opt/julia-${toolVersion}/bin \
   --run="julia -e 'using Pkg; Pkg.add(\"MriResearchTools\")'" \
   --env DEPLOY_BINS=julia \
   --entrypoint /opt/julia-${toolVersion}/bin \
   --copy README.md /README.md \
  > ${imageName}.Dockerfile

sed -i 's/toolVersion/${toolVersion}/' README.md