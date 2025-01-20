#!/usr/bin/env bash
set -e

# this template file builds tools required for dicom conversion to bids
export toolName='palmettobug'
export toolVersion='0.0.2'    # Don't forget to update version change in README.md!!!!!


if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh --reinstall_neurodocker=false

neurodocker generate ${neurodocker_buildMode} \
    --pkg-manager apt \
    --base-image ubuntu:24.04 \
    --env DEBIAN_FRONTEND=noninteractive \
    --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
    --run="chmod +x /usr/bin/ll" \
    --run="mkdir -p ${mountPointList}" \
    --install ca-certificates wget unzip libx11-6 fontconfig libgles2 \
    --workdir /opt \
    --miniconda version=latest \
                conda_install="python=3.9" \
    --run="wget https://object-store.rc.nectar.org.au/v1/AUTH_dead991e1fa847e3afcca2d3a7041f5d/build/CIPHER-main-20250120.zip \
      && unzip CIPHER-main-20250120 \
      && rm -rf CIPHER-main-20250120 \
      && cd CIPHER-main \
      && pip install . \
      && cd .. \
      && rm -rf CIPHER-main" \
    --env DEPLOY_BINS=palmettobug \
    --copy README.md /README.md \
  > ${imageName}.${neurodocker_buildExt}


if [ "$1" != "" ]; then
   ./../main_build.sh
fi