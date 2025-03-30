#!/usr/bin/env bash
set -e

export toolName='cpac'
export toolVersion='1.8.7'

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base-image fcpindi/c-pac:release-v1.8.7.post1.dev3 \
   --pkg-manager apt \
   --run="pip install --upgrade setuptools" \
   --run="pip install --upgrade backports.tarfile" \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir -p ${mountPointList}" \
   --env DEPLOY_BINS=cpac \
   --copy README.md /README.md \
   --workdir /tmp \
   > ${imageName}.${neurodocker_buildExt}

if [ "$1" != "" ]; then
   ./../main_build.sh
fi