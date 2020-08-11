#!/usr/bin/env bash
set -e

export toolName='afni'
export toolVersion=`wget -O- https://afni.nimh.nih.gov/pub/dist/AFNI.version | head -n 1 | cut -d '_' -f 2`

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
  > ${imageName}.Dockerfile
