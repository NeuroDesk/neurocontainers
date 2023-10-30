#!/usr/bin/env bash
set -e

# this template file builds tools required for dicom conversion to bids
export toolName='bidscoin'
export toolVersion='4.2.1'
# Don't forget to update version change in README.md!!!!!

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

# Changes made to .def file:
# 1. turned the apt-get install to neurodocker install
# 2. put commands with cd with && in between
# TODO: update these list items to better reflect the changes made
neurodocker generate ${neurodocker_buildMode} `# Based on Singularity .def file provided by bidscoin at https://github.com/Donders-Institute/bidscoin/blob/master/singularity.def` \
    `# Install the latest dcm2niix from source` \
    --pkg-manager apt \
    --base-image debian:stable \
    --env DEBIAN_FRONTEND=noninteractive \
    --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
    --run="chmod +x /usr/bin/ll" \
    --run="mkdir -p ${mountPointList}" \
    --install git build-essential cmake \
    --run "export GIT_SSL_NO_VERIFY=1 && git clone https://github.com/rordenlab/dcm2niix.git" `# first command solves some issue with the close as explaine here: https://stackoverflow.com/questions/21181231/server-certificate-verification-failed-cafile-etc-ssl-certs-ca-certificates-c` \
    --run "cd dcm2niix; mkdir build && cd build; cmake ..; make install" \
    `#  Install curl (sometimes needed by dcm2niix)` \
    --install curl \
    `# Install pigz (to speed up dcm2niix)` \
    --install pigz \
    `# Install the 4.2.1+Qt5 branch from Github` \
    `# NOTE: PyQt5 is installed as Debian package to solve dependencies issues occurring when installed with pip.` \
    --install python3-pyqt5 \
    --miniconda version=latest \
		pip_install='bidscoin[spec2nii2bids,deface]@git+https://github.com/Donders-Institute/bidscoin@v4.2.1+qt5' \
   --env DEPLOY_BINS=bidscoin:bidscoiner:bidseditor:bidsmapper:bidsparticipants:deface:dicomsort:echocombine:medeface:physio2tsv:plotphysio:rawmapper:skullstrip:slicereport:dcm2niix:pydeface:spec2nii \
   --copy README.md /README.md \
  > ${toolName}_${toolVersion}.Dockerfile

if [ "$1" != "" ]; then
   ./../main_build.sh
fi
