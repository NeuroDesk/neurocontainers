#!/usr/bin/env bash
set -e

export toolName='fsl'
export toolVersion='6.0.3'

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base ubuntu:16.04 \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir ${mountPointList}" \
   --${toolName} version=${toolVersion} \
   --env FSLOUTPUTTYPE=NIFTI_GZ \
   --env DEPLOY_PATH=/opt/${toolName}/bin/:/opt/${toolName}/fslpython/envs/fslpython/bin/ \
   --user=neuro \
  > ${imageName}.Dockerfile
