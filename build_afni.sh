#!/usr/bin/env bash
set -e

# https://afni.nimh.nih.gov/
export toolName='afni'
export toolVersion='20p0p23'

source main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base debian:stretch \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir ${mountPointList}" \
   --afni version=latest \
   --env DEPLOY_PATH=/opt/afni-latest/bin/ \
   --user=neuro \
  > recipe.${imageName}

./main_build.sh
