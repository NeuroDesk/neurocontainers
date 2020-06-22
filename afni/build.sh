#!/usr/bin/env bash
set -e

export toolName='afni'
# check latest version number here https://afni.nimh.nih.gov/ Current AFNI Version
export toolVersion='20.1.17'

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base centos:7 \
   --pkg-manager yum \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir ${mountPointList}" \
   --afni version=latest method=binaries install_r_pkgs='true' install_python3='true' \
   --miniconda create_env=neuro conda_install='python=3.6' \
   --env DEPLOY_PATH=/opt/${toolName}-latest/ \
   --user=neuro \
  > recipe.${imageName}

./../main_build.sh
