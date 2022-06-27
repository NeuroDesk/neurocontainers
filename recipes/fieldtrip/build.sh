#!/usr/bin/env bash
set -e

# this template file builds fieldtrip and is then used as a docker base image for layer caching
export toolName='fieldtrip'
export toolVersion='20220617'
# Don't forget to update version change in README.md!!!!!

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi


source ../main_setup.sh



neurodocker generate ${neurodocker_buildMode} \
   --base-image ubuntu:18.04 \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir ${mountPointList}" \
   --install curl unzip ca-certificates openjdk-8-jre dbus-x11 \
   --matlabmcr version=2020b install_path=/opt/MCR  \
   --workdir /opt/${toolName}-${toolVersion}/ \
   --run="curl -fsSL --retry 5 https://objectstorage.us-ashburn-1.oraclecloud.com/p/b_NtFg0a37NZ-3nJfcTk_LSCadJUyN7IkhhVDB7pv8GGQ2e0brg8kYUnAwFfYb6N/n/sd63xuke79z3/b/neurodesk/o/fieldtrip20220617_mcr2020b.tar.gz \
      | tar -xz -C /opt/${toolName}-${toolVersion}/ --strip-components 1 \
      && chmod +x /opt/${toolName}-${toolVersion}/*" \
   --env PATH=/opt/${toolName}-${toolVersion}/:$PATH \
   --env DEPLOY_BINS=run_fieldtrip.sh \
   --copy README.md /README.md \
  > ${imageName}.${neurodocker_buildExt}

if [ "$1" != "" ]; then
   ./../main_build.sh
fi
