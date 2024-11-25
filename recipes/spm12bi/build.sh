#!/usr/bin/env bash
set -e

# this template file builds spm12
export toolName='spm12bi'
export toolVersion='latest'
# Don't forget to update version change in README.md!!!!!

# Batteries included version: 

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

export MATLAB_VERSION=R2019b
export MCR_VERSION=v97
export MCR_UPDATE=9
export SPM_VERSION=12
export SPM_REVISION=$toolVersion

neurodocker generate ${neurodocker_buildMode} \
   --base-image ubuntu:16.04 \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir -p ${mountPointList}" \
   --install wget unzip ca-certificates openjdk-8-jre dbus-x11 \
   --env MATLAB_VERSION=$MATLAB_VERSION \
   --env MCR_VERSION=$MCR_VERSION \
   --env MCR_UPDATE=$MCR_UPDATE \
   --matlabmcr version=2019b install_path=/opt/mcr  \
   --env SPM_VERSION=$SPM_VERSION \
   --env SPM_REVISION=$toolVersion \
   --env MCR_INHIBIT_CTF_LOCK=1 \
   --env SPM_HTML_BROWSER=0 \
   --run="wget --no-check-certificate --progress=bar:force -P /opt https://www.fil.ion.ucl.ac.uk/spm/download/restricted/utopia/dev/spm12_latest_BI_Linux_R2019b.zip \
      && unzip -q /opt/spm12_latest_BI_Linux_R2019b.zip -d /opt \
      && rm -f /opt/spm12_latest_BI_Linux_R2019b.zip" \
   --env LD_LIBRARY_PATH=/opt/mcr/${MCR_VERSION}/runtime/glnxa64:/opt/mcr/${MCR_VERSION}/bin/glnxa64:/opt/mcr/${MCR_VERSION}/sys/os/glnxa64:/opt/mcr/${MCR_VERSION}/sys/opengl/lib/glnxa64:/opt/mcr/${MCR_VERSION}/extern/bin/glnxa64 \
   --run="/opt/spm${SPM_VERSION}/spm${SPM_VERSION} function exit \
      && chmod +x /opt/spm${SPM_VERSION}/*" \
   --miniconda \
         version=latest \
         conda_install='python=3.8 traits nipype numpy scipy h5py scikit-image' \
   --env XAPPLRESDIR=/opt/mcr/${MCR_VERSION}/x11/app-defaults \
   --env DEPLOY_BINS=run_spm12.sh:spm12 \
   --env PATH=/opt/spm12:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
   --copy README.md /README.md \
  > ${toolName}_${toolVersion}.${neurodocker_buildExt}


if [ "$1" != "" ]; then
   ./../main_build.sh
fi
