#!/usr/bin/env bash
set -e

# this template file builds conn
export toolName='conn'
export toolVersion='18b'

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug="true"
fi

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base ubuntu:20.04 \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir ${mountPointList}" \
   --run="curl -fsSL --retry 5 -o /tmp/conn18b_glnxa64.zip https://www.nitrc.org/frs/download.php/11120/conn18b_glnxa64.zip" \
   --run="unzip -q /tmp/conn18b_glnxa64.zip -d /opt/conn-18b/" \
   --matlabmcr version=2019a method=binaries \
   --env DEPLOY_BINS=conn \
   --env PATH=/opt/conn-18b/:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
   --copy README.md /README.md \
  > ${toolName}_${toolVersion}.Dockerfile

if [ "$debug" = "true" ]; then
   ./../main_build.sh
fi
