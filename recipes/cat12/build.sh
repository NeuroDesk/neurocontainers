#!/usr/bin/env bash
set -e

# this template file builds cat12, new versions here: http://141.35.69.218/cat12/?C=M;O=D
export toolName='cat12'
export toolVersion='r1933'
# Don't forget to update version change in README.md!!!!!

# inspired by: https://github.com/m-wierzba/cat-container/blob/master/Singularity
# discussed here: https://github.com/ReproNim/neurodocker/issues/407

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

# once this is working contribute this to neurodocker project:
# yes | pip uninstall neurodocker
# pip install --no-cache-dir https://github.com/NeuroDesk/neurodocker/tarball/xxx --upgrade

export MATLAB_VERSION=R2017b
export MCR_VERSION=v93
export MCR_UPDATE=9
export CAT_VERSION=12.8
export CAT_REVISION=$toolVersion

neurodocker generate ${neurodocker_buildMode} \
   --base-image ubuntu:16.04 \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir ${mountPointList}" \
   --install wget unzip ca-certificates openjdk-8-jre dbus-x11 \
   --env MATLAB_VERSION=$MATLAB_VERSION \
   --env MCR_VERSION=$MCR_VERSION \
   --env MCR_UPDATE=$MCR_UPDATE \
   --matlabmcr version=2017b install_path=/opt/mcr  \
   --env CAT_VERSION=$CAT_VERSION \
   --env CAT_REVISION=$toolVersion \
   --env MCR_INHIBIT_CTF_LOCK=1 \
   --env SPM_HTML_BROWSER=0 \
   --env SPMROOT=/opt/spm${CAT_VERSION}/ \
   --env MCRROOT=/opt/mcr/${MCR_VERSION} \
   --env MCR_INHIBIT_CTF_LOCK=1v \
   --run="wget --no-check-certificate --progress=bar:force -P /opt http://www.neuro.uni-jena.de/cat12/CAT${CAT_VERSION}_${CAT_REVISION}_${MATLAB_VERSION}_MCR_Linux.zip \
      && unzip -q /opt/CAT${CAT_VERSION}_${CAT_REVISION}_${MATLAB_VERSION}_MCR_Linux.zip -d /opt \
      && ln -s  /opt/CAT${CAT_VERSION}_${CAT_REVISION}_${MATLAB_VERSION}_MCR_Linux /opt/cat12 \
      && rm -f /opt/CAT${CAT_VERSION}_${CAT_REVISION}_${MATLAB_VERSION}_MCR_Linux.zip" \
   --miniconda \
         version=latest \
         conda_install='python=3.8 traits nipype numpy scipy h5py scikit-image' \
   --env LD_LIBRARY_PATH=/opt/mcr/${MCR_VERSION}/runtime/glnxa64:/opt/mcr/${MCR_VERSION}/bin/glnxa64:/opt/mcr/${MCR_VERSION}/sys/os/glnxa64:/opt/mcr/${MCR_VERSION}/sys/opengl/lib/glnxa64:/opt/mcr/${MCR_VERSION}/extern/bin/glnxa64 \
   --run="/opt/CAT${CAT_VERSION}_${CAT_REVISION}_${MATLAB_VERSION}_MCR_Linux/spm12 function exit \
      && chmod +x /opt/CAT${CAT_VERSION}_${CAT_REVISION}_${MATLAB_VERSION}_MCR_Linux/*" \
   --env XAPPLRESDIR=/opt/mcr/${MCR_VERSION}/x11/app-defaults \
   --env DEPLOY_BINS=run_spm12.sh:spm12 \
   --env PATH=/opt/CAT${CAT_VERSION}_${CAT_REVISION}_${MATLAB_VERSION}_MCR_Linux:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
   --copy README.md /README.md \
  > ${toolName}_${toolVersion}.${neurodocker_buildExt}

      # && rm -rf /opt/CAT${CAT_VERSION}_${CAT_REVISION}_${MATLAB_VERSION}_MCR_Linux/spm12_mcr/home/ \

if [ "$1" != "" ]; then
   ./../main_build.sh
fi


# TESTS:
