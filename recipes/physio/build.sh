#!/usr/bin/env bash
set -e

# this template file builds spm12
export toolName='physio'
export toolVersion='r2021a'
# Don't forget to update version change in README.md!!!!!

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

# once this is working contribute this to neurodocker project:
# (tried to do it, but neurodocker currently hardcodes the mcr version)
# yes | pip uninstall neurodocker
# pip install --no-cache-dir https://github.com/NeuroDesk/neurodocker/tarball/update-spm12 --upgrade

# try slimdown version next: https://github.com/spm/spm-docker/pull/2

export MATLAB_VERSION=2020b #warning: 2021a currently does not work in the container as it tries to write things to disk on startup
export MCR_VERSION=v99
export SPM_VERSION=12
export SPM_REVISION=r8224

neurodocker generate ${neurodocker_buildMode} \
   --base-image ubuntu:16.04 \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir -p ${mountPointList}" \
   --install wget unzip ca-certificates openjdk-8-jre dbus-x11 \
   --env MATLAB_VERSION=R$MATLAB_VERSION \
   --env MCR_VERSION=$MCR_VERSION \
   --matlabmcr version=$MATLAB_VERSION install_path=/opt/mcr  \
   --env SPM_VERSION=$SPM_VERSION \
   --env SPM_REVISION=$toolVersion \
   --env MCR_INHIBIT_CTF_LOCK=1 \
   --env SPM_HTML_BROWSER=0 \
   --workdir /opt/spm${SPM_VERSION}/ \
   --run="curl -fsSL --retry 5 https://object-store.rc.nectar.org.au/v1/AUTH_dead991e1fa847e3afcca2d3a7041f5d/build/spm12r8224_physioR2021a_standalone_MCRv99_MatlabR2020b_Linux.tar.gz \
      | tar -xz -C /opt/spm${SPM_VERSION}/ --strip-components 1" \
   --env LD_LIBRARY_PATH=/opt/mcr/${MCR_VERSION}/runtime/glnxa64:/opt/mcr/${MCR_VERSION}/bin/glnxa64:/opt/mcr/${MCR_VERSION}/sys/os/glnxa64:/opt/mcr/${MCR_VERSION}/sys/opengl/lib/glnxa64:/opt/mcr/${MCR_VERSION}/extern/bin/glnxa64 \
   --run="/opt/spm${SPM_VERSION}/spm${SPM_VERSION} function exit \
      && chmod +rx /opt/spm${SPM_VERSION}/* -R" \
   --env XAPPLRESDIR=/opt/mcr/${MCR_VERSION}/x11/app-defaults \
   --env DEPLOY_BINS=run_spm12.sh:spm12 \
   --env PATH=/opt/spm12:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
   --copy README.md /README.md \
  > ${toolName}_${toolVersion}.${neurodocker_buildExt}


if [ "$1" != "" ]; then
   ./../main_build.sh
fi
