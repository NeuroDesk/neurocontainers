#!/usr/bin/env bash
set -e

export toolName='mrtrix3'
export toolVersion='3.0.0'

source ../main_setup.sh

# export localSingularityBuild='false'
# export localSingularityBuildWritable='true'

neurodocker generate ${neurodocker_buildMode} \
   --base ubuntu:16.04 \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir ${mountPointList}" \
   --${toolName} version=${toolVersion} method="source" \
   --fsl version="6.0.3" install_path="/opt/fsl" \
   --env DEPLOY_PATH=/opt/${toolName}-${toolVersion}/bin/ \
   --user=neuro \
  > recipe.${imageName}

./../main_build.sh
