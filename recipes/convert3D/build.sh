#!/usr/bin/env bash
set -e

export toolName='convert3d'
export toolVersion=1.0.0

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base-image debian:stretch \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir ${mountPointList}" \
   --convert3d version=${toolVersion} \
   --env DEPLOY_PATH=/opt/convert3d-${toolVersion}/bin/ \
   --copy README.md /README.md \
   --user=neuro \
  > ${imageName}.Dockerfile
