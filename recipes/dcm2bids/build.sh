#!/usr/bin/env bash
set -e
export toolName='dcm2bids'
export toolVersion='3.2.0'
 
if [ "$1" != "" ]; then
echo "Entering Debug mode"
export debug=$1
fi
 
source ../main_setup.sh
 
neurodocker generate ${neurodocker_buildMode} \
--base-image unfmontreal/dcm2bids:3.2.0 \
--pkg-manager apt \
--env DEBIAN_FRONTEND=noninteractive \
--run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
--run="chmod +x /usr/bin/ll" \
--run="mkdir -p ${mountPointList}" \
--copy README.md /README.md \
> ${toolName}_${toolVersion}.Dockerfile 
if [ "$1" != "" ]; then 
./../main_build.sh 
fi