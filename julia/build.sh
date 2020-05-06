#!/usr/bin/env bash
set -e

export toolName='julia'
export toolVersion='1.4.1'

source ../main_setup.sh

# export localSingularityBuild='false'
# export localSingularityBuildWritable='true'

neurodocker generate ${neurodocker_buildMode} \
   --base ubuntu:20.04 \
   --pkg-manager apt \
   --run="mkdir ${mountPointList}" \
   --install $toolName \
   --env DEPLOY_PATH=/usr/bin/$toolName \
   --entrypoint /usr/bin/$toolName \
   --user=neuro \
  > recipe.${imageName}

./../main_build.sh
