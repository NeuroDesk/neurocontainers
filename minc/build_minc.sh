#!/usr/bin/env bash
set -e

export toolName='minc'
export toolVersion=1.9.16

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base centos:7 \
   --pkg-manager yum \
   --run="mkdir ${mountPointList}" \
   --${toolName} version=${toolVersion} \
   --env DEPLOY_PATH=/opt/${toolName}-${toolVersion}/bin/ \
  > recipe.${imageName}

./../main_build.sh
