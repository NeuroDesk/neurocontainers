#!/usr/bin/env bash
set -ex

export toolName='brkraw'
export toolVersion='0.3.11'

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

echo "EXPERIMENTAL: using tinyrange"

$TINYRANGE login \
    --package-path brkraw.pkg \
    --pkg brkraw \
    --exec "whoami" \
    --pull-snapshot brkraw.tar.gz

neurodocker generate ${neurodocker_buildMode} \
    --base-image alpine \
    --pkg-manager apt \
    --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
    --run="chmod +x /usr/bin/ll" \
    --run="mkdir -p ${mountPointList}" \
    --add ./brkraw.tar.gz / \
    --copy README.md /README.md \
> ${imageName}.${neurodocker_buildExt}

if [ "$1" != "" ]; then
   ./../main_build.sh
fi