#!/usr/bin/env bash
set -e

export toolName='mrtrix3'
export toolVersion='3.0.0'

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base vnmd/ants_2.3.1:latest \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir ${mountPointList}" \
   --${toolName} version=${toolVersion} method="source" \
   --fsl version="6.0.3" install_path="/opt/fsl" \
   --env DEPLOY_PATH=/opt/${toolName}-${toolVersion}/bin/ \
   --user=neuro \
  > ${imageName}.Dockerfile
