#!/usr/bin/env bash
set -e

export toolName='dcm2niix'
export toolVersion='v1.0.20240202'

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
    --install git wget ca-certificates pigz \
    --workdir /opt/${toolName}-${toolVersion} \
    --run="curl -fLO https://github.com/rordenlab/dcm2niix/releases/latest/download/dcm2niix_lnx.zip \
        && unzip dcm2niix_lnx.zip \
        && chmod a+rwx /opt/${toolName}-${toolVersion}/${toolName} \
        && rm -rf dcm2niix_lnx.zip" \
    --env PATH='$PATH':/opt/${toolName}-${toolVersion} \
    --env DEPLOY_PATH=/opt/${toolName}-${toolVersion} \
    --copy README.md /README.md \
> ${imageName}.${neurodocker_buildExt}

if [ "$1" != "" ]; then
    ./../main_build.sh
fi