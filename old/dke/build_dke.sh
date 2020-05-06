#!/usr/bin/env bash
# Diffusional Kurtosis Estimator - DKE Fiber Tracking
# https://www.nitrc.org/frs/?group_id=652
set -e

export toolName='dke'
export toolVersion='1.0.0'

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base debian:stretch \
   --pkg-manager apt \
   --install wget zip \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir ${mountPointList}" \
   --run="curl -O Linux_FT.zip" \
   --run="unzip /opt/Linux_FT.zip" \
   --env DEPLOY_PATH=/opt/${toolName}-${toolVersion}/bin/ \
   --user=neuro \
  > recipe.${imageName}

./../main_build.sh
