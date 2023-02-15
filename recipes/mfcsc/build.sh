#!/usr/bin/env bash
set -e

# this template file builds eeglab and is then used as a docker base image for layer caching
export toolName='mfcsc'
export toolVersion='1.0'
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
   --matlabmcr version=2020a install_path=/opt/MCR  \
   --workdir /opt/${toolName}-${toolVersion}/ \
   --run="curl -fsSL --retry 5 https://swift.rc.nectar.org.au/v1/AUTH_dead991e1fa847e3afcca2d3a7041f5d/neurodesk/mfcsc1.0_mcr2020a.tar.gz \
      | tar -xz -C /opt/${toolName}-${toolVersion}/" `# NOTICE: use access URL without pre-authorised token` \
   `# --env XAPPLRESDIR=/opt/MCR/v98/x11/app-defaults` \
   --run="chmod a+x /opt/${toolName}-${toolVersion}/*" `# give everybody permission to run because files are owned by rooot, and by default, only owner has execute permission` \
   --env PATH=/opt/${toolName}-${toolVersion}/:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
   --env DEPLOY_BINS=mfcsc \
   --copy README.md /README.md \
  > ${imageName}.${neurodocker_buildExt}

if [ "$1" != "" ]; then
   ./../main_build.sh
fi
