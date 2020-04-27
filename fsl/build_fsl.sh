#!/usr/bin/env bash
set -e

export toolName='fsl'
export toolVersion='6.0.3'

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base debian:stretch \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir ${mountPointList}" \
   --fsl version=${toolVersion} \
   --env FSLOUTPUTTYPE=NIFTI_GZ \
   --env DEPLOY_PATH=/opt/fsl-${toolVersion}/bin/:/opt/fsl-${toolVersion}/fslpython/envs/fslpython/bin/ \
   --user=neuro \
  > recipe.${imageName}

./../main_build.sh
