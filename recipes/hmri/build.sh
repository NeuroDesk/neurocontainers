#!/usr/bin/env bash
set -e

export toolName='hmri'
export toolVersion='0.6.1'

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

export MATLAB_VERSION=2023a
export MCR_VERSION=R2023a
export MCR_UPDATE=9
export SPM_VERSION=12
export SPM_REVISION=7771

neurodocker generate ${neurodocker_buildMode} \
   --base-image ubuntu:20.04 \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir -p ${mountPointList}" \
   --install wget unzip ca-certificates openjdk-8-jre dbus-x11 \
   --matlabmcr version=2023a install_path=/opt/mcr  \
   --run="wget --no-check-certificate --progress=bar:force -P /opt https://github.com/hMRI-group/hMRI-toolbox/releases/download/v${toolVersion}/standalone-hMRItoolboxv${toolVersion}.zip \
      && unzip -q /opt/standalone-hMRItoolboxv${toolVersion}.zip -d /opt \
      && rm -f /opt/standalone-hMRItoolboxv${toolVersion}.zip \
      && chmod a+rx /opt/standalone/ -R" \
   --env SPM_VERSION=$SPM_VERSION \
   --env SPM_REVISION=r$SPM_REVISION \
   --env MCR_INHIBIT_CTF_LOCK=1 \
   --env SPM_HTML_BROWSER=0 \
   --env MATLAB_VERSION=R$MATLAB_VERSION \
   --env MCR_VERSION=$MCR_VERSION \
   --env MCR_UPDATE=$MCR_UPDATE \
   --env LD_LIBRARY_PATH='$LD_LIBRARY_PATH':/opt/mcr/${MCR_VERSION}/runtime/glnxa64:/opt/mcr/${MCR_VERSION}/bin/glnxa64:/opt/mcr/${MCR_VERSION}/sys/os/glnxa64:/opt/mcr/${MCR_VERSION}/sys/opengl/lib/glnxa64:/opt/mcr/${MCR_VERSION}/extern/bin/glnxa64 \
   --env XAPPLRESDIR=/opt/mcr/${MCR_VERSION}/x11/app-defaults \
   --env DEPLOY_BINS=run_spm12.sh:spm12 \
   --run="/opt/standalone/spm${SPM_VERSION} function exit \
         && chmod a+rx /opt/standalone/ -R" \
   --env PATH='$PATH':/opt/standalone \
   --env DEPLOY_ENV_FORCE_SPMMCR="1" \
   --copy README.md /README.md \
  > ${toolName}_${toolVersion}.${neurodocker_buildExt}



if [ "$1" != "" ]; then
   ./../main_build.sh
fi
