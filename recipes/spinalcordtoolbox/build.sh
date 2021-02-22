#!/usr/bin/env bash
set -e

export toolName='spinalcordtoolbox'
export toolVersion='5.1.0'

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
   --user=${toolName} \
   --workdir="/opt/${toolName}-${toolVersion}" \
   --run="yes | ./install_sct" \
   --env DEPLOY_PATH=/home/${toolName}/sct_${toolVersion}/bin/ \
   --env PATH=/home/${toolName}/sct_${toolVersion}/bin/:$PATH \
   --copy README.md /README.md \
  > ${toolName}_${toolVersion}.Dockerfile


if [ "$debug" = "true" ]; then
   ./../main_build.sh
fi
