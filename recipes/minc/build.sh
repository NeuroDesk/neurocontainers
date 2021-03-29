#!/usr/bin/env bash
set -e

export toolName='minc'
export toolVersion=1.9.17

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base ubuntu:18.04 \
   --pkg-manager apt \
   --run="mkdir ${mountPointList}" \
   --copy README.md /README.md \
   --${toolName} version=${toolVersion} \
   --env DEPLOY_PATH=/opt/${toolName}-${toolVersion}/bin/:/opt/${toolName}-${toolVersion}/volgenmodel-nipype/extra-scripts:/opt/${toolName}-${toolVersion}/pipeline \
  > ${imageName}.Dockerfile