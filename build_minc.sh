#!/usr/bin/env bash
set -e

export toolName='minc'
export toolVersion=1.9.17

source main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base centos:6 \
   --pkg-manager yum \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir ${mountPointList}" \
   --${toolName} version=${toolVersion} \
   --env DEPLOY_PATH=/opt/${toolName}-${toolVersion}/bin/ \
   --user=neuro \
  > recipe.${imageName}

./main_build.sh
