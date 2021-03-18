#!/usr/bin/env bash
set -e

# this template file builds itksnap and is then used as a docker base image for layer caching
export toolName='hdbet'
export toolVersion='1.0.0'

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug="true"
fi

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base ubuntu:16.04 \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir ${mountPointList}" \
   --install git \
   --miniconda use_env=base \
         conda_install='python=3.6' \
   --workdir /opt \
   --run="git clone https://github.com/MIC-DKFZ/HD-BET" \
   --workdir /opt/HD-BET \
   --run="pip install -e ." \
   --env DEPLOY_BINS=hd-bet \
   --copy README.md /README.md \
  > ${toolName}_${toolVersion}.Dockerfile

if [ "$debug" = "true" ]; then
   ./../main_build.sh
fi

   # --run="curl -o /opt/example_data.nii.gz -L https://files.au-1.osf.io/v1/resources/bt4ez/providers/osfstorage/5e9bf3e2d697350662be21ab" \
#   --run="echo 'import os' > /opt/HD-BET/HD_BET/paths.py" \
#    --run="echo 'folder_with_parameter_files = \"/opt/HD-BET/hd-bet_params\"' >> /opt/HD-BET/HD_BET/paths.py" \
   # --run="hd-bet -i /opt/example_data.nii.gz -device cpu -mode fast -tta 0" \
