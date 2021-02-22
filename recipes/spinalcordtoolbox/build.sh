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
   --install="gcc libmpich-dev python3-pyqt5 git curl bzip2 libglib2.0-0" \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir ${mountPointList}" \
   --run="curl -fsSL --retry 5 https://github.com/neuropoly/spinalcordtoolbox/archive/${toolVersion}.tar.gz | tar -xz -C /opt/ " \
   --workdir="/opt/${toolName}-${toolVersion}" \
   --run="chmod a+rwx /opt/${toolName}-${toolVersion}/spinalcordtoolbox" \
   --run="chmod a+rwx /opt/${toolName}-${toolVersion}/" \
   --user=${toolName} \
   --run="yes | ./install_sct -i" \
   --env DEPLOY_PATH=/opt/${toolName}-${toolVersion}/bin/ \
   --env PATH=/opt/${toolName}-${toolVersion}/bin/:$PATH \
   --copy README.md /README.md \
  > ${toolName}_${toolVersion}.Dockerfile


if [ "$debug" = "true" ]; then
   ./../main_build.sh
fi
