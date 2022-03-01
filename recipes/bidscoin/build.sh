#!/usr/bin/env bash
set -e

# this template file builds tools required for dicom conversion to bids
export toolName='bidscoin'
export toolVersion='3.7.0'
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
   --run="mkdir ${mountPointList}" \
   --miniconda version=latest \
              pip_install='bidscoin' \
   --env DEPLOY_BINS=bidsmapper:bidscoiner:dicomsort:rawmapper:echocombine:deface:medeface:bidseditor:bidsparticipants \
   --copy README.md /README.md \
  > ${toolName}_${toolVersion}.Dockerfile

if [ "$1" != "" ]; then
   ./../main_build.sh
fi
