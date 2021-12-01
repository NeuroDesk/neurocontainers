#!/usr/bin/env bash
set -e

export toolName='ants'
export toolVersion='2.3.4'
# Don't forget to update version change in README.md!!!!!

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base-image ubuntu:16.04 \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir ${mountPointList}" \
   --ants version=${toolVersion} \
   --env DEPLOY_PATH=/opt/ants-${toolVersion}/ \
   --copy README.md /README.md \
  > ${imageName}.Dockerfile
