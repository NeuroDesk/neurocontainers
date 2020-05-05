#!/usr/bin/env bash
set -e

export toolName='itksnap'
export toolVersion='3.8.0'

source ../main_setup.sh

# export localSingularityBuild='false'
# export localSingularityBuildWritable='true'

neurodocker generate ${neurodocker_buildMode} \
   --base ubuntu:16.04 \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir ${mountPointList}" \
   --${toolName} version=master method=source \
   --env DEPLOY_PATH=/opt/${toolName}-${toolVersion}/bin/ \
   --entrypoint /opt/${toolName}-${toolVersion}/bin/itksnap \
   --user=neuro \
  > recipe.${imageName}

./../main_build.sh
