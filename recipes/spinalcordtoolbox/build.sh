#!/usr/bin/env bash
set -e

export toolName='spinalcordtoolbox'
export toolVersion='4.3'

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug="true"
fi

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base ubuntu:16.04 \
   --pkg-manager apt \
   --install="gcc libmpich-dev python3-pyqt5" \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir ${mountPointList}" \
   --run="curl -fsSL --retry 5 https://github.com/neuropoly/spinalcordtoolbox/archive/${toolVersion}.tar.gz | tar -xz -C /opt/ " \
   --user=neuro \
   --workdir="/opt/${toolName}-${toolVersion}" \
   --run="yes | ./install_sct" \
   --env DEPLOY_PATH=/home/neuro/sct_${toolVersion}/bin/ \
   --env PATH=/home/neuro/sct_${toolVersion}/bin/:$PATH \
  > ${toolName}_${toolVersion}.Dockerfile


if [ "$debug" = "true" ]; then
   ./../main_build.sh
fi
