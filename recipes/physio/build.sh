#!/usr/bin/env bash
set -e

# this template file builds spm12
export toolName='physio'
export toolVersion='r7771'
# Don't forget to update version change in README.md!!!!!

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug="true"
fi

source ../main_setup.sh

# once this is working contribute this to neurodocker project:
# (tried to do it, but neurodocker currently hardcodes the mcr version)
# yes | pip uninstall neurodocker
# pip install --no-cache-dir https://github.com/NeuroDesk/neurodocker/tarball/update-spm12 --upgrade

# try slimdown version next: https://github.com/spm/spm-docker/pull/2

export MATLAB_VERSION=2020b
export MCR_VERSION=v99
export SPM_VERSION=12
export SPM_REVISION=$toolVersion

neurodocker generate ${neurodocker_buildMode} \
   --base-image ubuntu:16.04 \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir ${mountPointList}" \
   --install wget unzip ca-certificates openjdk-8-jre dbus-x11 \
   --env MATLAB_VERSION=R$MATLAB_VERSION \
   --env MCR_VERSION=$MCR_VERSION \
   --matlabmcr version=$MATLAB_VERSION install_path=/opt/mcr  \
   --env SPM_VERSION=$SPM_VERSION \
   --env SPM_REVISION=$toolVersion \
   --env MCR_INHIBIT_CTF_LOCK=1 \
   --env SPM_HTML_BROWSER=0 \
   --workdir /opt/spm${SPM_VERSION}/ \
   --run="curl -fsSL --retry 5 https://objectstorage.us-ashburn-1.oraclecloud.com/p/b_NtFg0a37NZ-3nJfcTk_LSCadJUyN7IkhhVDB7pv8GGQ2e0brg8kYUnAwFfYb6N/n/sd63xuke79z3/b/neurodesk/o/spm12_dev_physio_standalone_MCRv99_MatlabR2020b_Linux.tar.gz \
      | tar -xz -C /opt/spm${SPM_VERSION}/ --strip-components 1" \
   --env LD_LIBRARY_PATH=/opt/mcr/${MCR_VERSION}/runtime/glnxa64:/opt/mcr/${MCR_VERSION}/bin/glnxa64:/opt/mcr/${MCR_VERSION}/sys/os/glnxa64:/opt/mcr/${MCR_VERSION}/sys/opengl/lib/glnxa64:/opt/mcr/${MCR_VERSION}/extern/bin/glnxa64 \
   --run="/opt/spm${SPM_VERSION}/spm${SPM_VERSION} function exit \
      && chmod +rx /opt/spm${SPM_VERSION}/* -R" \
   --env XAPPLRESDIR=/opt/mcr/${MCR_VERSION}/x11/app-defaults \
   --env DEPLOY_BINS=run_spm12.sh:spm12 \
   --env PATH=/opt/spm12:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
   --copy README.md /README.md \
  > ${toolName}_${toolVersion}.${neurodocker_buildExt}


if [ "$debug" = "true" ]; then
   ./../main_build.sh
fi
