#!/usr/bin/env bash
set -e

export toolName='brainstorm'
export toolVersion='3.211130'
# Don't forget to update version change in README.md!!!!!

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug="true"
fi

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base-image ubuntu:18.04 \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir ${mountPointList}" \
   --install curl unzip ca-certificates openjdk-8-jre dbus-x11 \
   --matlabmcr version=2020a install_path=/opt/MCR  \
   --workdir /opt/${toolName}-${toolVersion}/ \
   --run="curl -fsSL --retry 5 https://objectstorage.us-ashburn-1.oraclecloud.com/p/b_NtFg0a37NZ-3nJfcTk_LSCadJUyN7IkhhVDB7pv8GGQ2e0brg8kYUnAwFfYb6N/n/sd63xuke79z3/b/neurodesk/o/brainstorm3.211130_mcr2020a.tar.gz \
      | tar -xz -C /opt/${toolName}-${toolVersion}/ --strip-components 1" \
   --entrypoint "/opt/${toolName}-${toolVersion}/brainstorm3.command /opt/MCR/v98 " \
   --env DEPLOY_PATH=/opt/${toolName}-${toolVersion}/ \
   --env DEPLOY_BINS=brainstorm3 \
   --copy README.md /README.md \
  > ${imageName}.${neurodocker_buildExt}

if [ "$debug" = "true" ]; then
   ./../main_build.sh
fi
