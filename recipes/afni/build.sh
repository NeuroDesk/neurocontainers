#!/usr/bin/env bash
set -e

export toolName='afni'
export toolVersion='20.1.18'

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base centos:7 \
   --pkg-manager yum \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir ${mountPointList}" \
   --afni version=${toolVersion} method=binaries install_r_pkgs='true' install_python3='true' \
   --miniconda create_env=neuro conda_install='python=3.6' \
   --env DEPLOY_PATH=/opt/${toolName}-${toolVersion}/ \
   --user=neuro \
  > ${imageName}.Dockerfile
