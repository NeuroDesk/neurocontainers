#!/usr/bin/env bash
set -e

# this template file builds tools required for dicom conversion to bids
export toolName='bidscoin'
export toolVersion='3.7.0'
# Don't forget to update version change in README.md!!!!!

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

# Changes I made to .def file:
# 1. turned the apt-get install to neurodocker install
# 2. put commands with cd with && in between
neurodocker generate ${neurodocker_buildMode} `# Based on Singularity .def file provided by bidscoin at https://github.com/Donders-Institute/bidscoin/blob/master/singularity.def` \
    `# Install the latest dcm2niix from source` \
    --pkg-manager apt \
    --base-image debian:stable \
    --env DEBIAN_FRONTEND=noninteractive \
    --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
    --run="chmod +x /usr/bin/ll" \
    --run="mkdir ${mountPointList}" \
    --install git build-essential cmake \
    --run "export GIT_SSL_NO_VERIFY=1 && git clone https://github.com/rordenlab/dcm2niix.git" `# first command solves some issue with the close as explaine here: https://stackoverflow.com/questions/21181231/server-certificate-verification-failed-cafile-etc-ssl-certs-ca-certificates-c` \
    --run "cd dcm2niix; mkdir build && cd build; cmake ..; make install" \
    `#  Install curl (sometimes needed by dcm2niix)` \
    --install curl \
    `# Install pigz (to speed up dcm2niix)` \
    --install pigz \
    `# Install the latest stable BIDScoin release from Python repository` \
    `# NOTE: PyQt5 is installed as Debian package to solve dependencies issues occurring when installed with pip.` \
    --install python3-pyqt5 \
    --miniconda version=latest \
		pip_install='bidscoin[spec2nii2bids,phys2bidscoin]' \
   --env DEPLOY_BINS=bidsmapper:bidscoiner:dicomsort:rawmapper:echocombine:deface:medeface:bidseditor:bidsparticipants \
   --copy README.md /README.md \
  > ${toolName}_${toolVersion}.Dockerfile

if [ "$1" != "" ]; then
   ./../main_build.sh
fi
