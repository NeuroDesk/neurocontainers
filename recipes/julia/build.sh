#!/usr/bin/env bash
set -e

export toolName='julia'
export toolVersion='1.4.1'

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base ubuntu:20.04 \
   --pkg-manager apt \
   --run="mkdir ${mountPointList}" \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --install zlib1g-dev libzstd1 $toolName \
   --env DEPLOY_BINS=julia \
   --entrypoint /usr/bin/$toolName \
   --copy README.md /README.md \
  > ${imageName}.Dockerfile
