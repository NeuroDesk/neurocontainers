#!/usr/bin/env bash
set -e

export toolName='niimath'
export toolVersion='1.0.0'

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

# Use Singlrity/Apptainer to run TinyRange to generate the rootfs.
singularity run docker://ghcr.io/tinyrange/tinyrange:stable build niimath.star:niimath_root -o niimath.tar

# Make sure the automaticcly included template doesn't add to the final layer.
neurodocker generate ${neurodocker_buildMode} \
    --base-image ubuntu \
    --pkg-manager apt \
    --base-image scratch \
    --add niimath.tar . \
    --run "/init -run-scripts /.pkg/scripts.json" \
    --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
    --run="chmod +x /usr/bin/ll" \
    --run="mkdir -p ${mountPointList}" \
    --entrypoint "/usr/bin/niimath" \
    --env DEPLOY_BINS=niimath \
    --copy README.md /README.md \
 > ${imageName}.${neurodocker_buildExt}

if [ "$1" != "" ]; then
   ./../main_build.sh
fi
