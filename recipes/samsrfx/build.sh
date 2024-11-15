#!/usr/bin/env bash
set -e

export toolName='samsrfx'
export toolVersion='v10'

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base-image ubuntu:22.04 \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir -p ${mountPointList}" \
   --matlabmcr version=2023b method=binaries \
   --install wget openjdk-8-jre dbus-x11 libgbm-dev \
   --workdir /opt/${toolName}-${toolVersion}/ \
   --run="wget --no-check-certificate --progress=bar:force -P /opt/${toolName}-${toolVersion}/ https://object-store.rc.nectar.org.au/v1/AUTH_dead991e1fa847e3afcca2d3a7041f5d/build/samsrf_${toolVersion}.zip \
      && unzip -q samsrf_${toolVersion}.zip -d /opt/${toolName}-${toolVersion}/ \
      && chmod a+x /opt/${toolName}-${toolVersion}/samsrf/SamSrfX \
      && rm -f samsrf_${toolVersion}.zip" \
   --env DEPLOY_BINS=samsrfx \
   --run="echo 'cd /opt/samsrfx-${toolVersion}/samsrf' > samsrfx \
         && echo './run_SamSrfX.sh /opt/MCR-2023b/R2023b/' >> samsrfx \
         && chmod a+x samsrfx" \
   --env PATH='$PATH':/opt/${toolName}-${toolVersion}/ \
   --copy README.md /README.md \
  > ${toolName}_${toolVersion}.Dockerfile

if [ "$1" != "" ]; then
   ./../main_build.sh
fi

# 