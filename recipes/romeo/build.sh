#!/usr/bin/env bash
set -e

export toolName='romeo'
export toolVersion='3.2.8' # https://github.com/korbinian90/ROMEO/releases/
# Don't forget to update version change in README.md!!!!!

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base-image ubuntu:20.04 \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir -p ${mountPointList}" \
   --install curl ca-certificates \
   --workdir /opt/${toolName}-${toolVersion}/ \
   --run="curl -fsSL --retry 5 https://github.com/korbinian90/ROMEO/releases/download/v${toolVersion}/romeo_linux_${toolVersion}.tar.gz \
      | tar -xz -C /opt/${toolName}-${toolVersion}/ --strip-components 1" \
   --env DEPLOY_PATH=/opt/${toolName}-${toolVersion}/bin \
   --env PATH=/opt/${toolName}-${toolVersion}/bin:${PATH} \
   --copy README.md /README.md \
  > ${imageName}.${neurodocker_buildExt}

if [ "$1" != "" ]; then
   ./../main_build.sh
fi


   
