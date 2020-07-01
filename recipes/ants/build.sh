#!/usr/bin/env bash
set -e

export toolName='ants'
export toolVersion='2.3.1'

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base debian:stretch \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir ${mountPointList}" \
   --ants version=${toolVersion} \
   --env DEPLOY_PATH=/opt/ants-${toolVersion}/ \
   --user=neuro \
  > ${imageName}.Dockerfile
