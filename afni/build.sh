#!/usr/bin/env bash
set -e


export toolName='afni'
# check latest version number here https://afni.nimh.nih.gov/ Current AFNI Version
export toolVersion='20.1.06'

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base debian:stretch \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir ${mountPointList}" \
   --afni version=latest \
   --env DEPLOY_PATH=/opt/${toolName}-latest/ \
   --user=neuro \
  > recipe.${imageName}

./../main_build.sh
