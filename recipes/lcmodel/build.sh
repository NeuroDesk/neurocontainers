#!/usr/bin/env bash
set -e

# this template file builds itksnap and is then used as a docker base image for layer caching
export toolName='lcmodel'
export toolVersion='6.3'
# Don't forget to update version change in README.md!!!!!

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base-image ubuntu:16.04 \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir ${mountPointList}" \
   --install="curl ca-certificates libxft2 libxss1 libtk8.5 libnet-ifconfig-wrapper-perl vim nano unzip gv unrar" \
   --workdir=/opt/${toolName}-${toolVersion}/ \
   --run="curl -o /opt/lcm-64.tar http://www.lcmodel.com/pub/LCModel/programs/lcm-64.tar && \
          tar xf /opt/lcm-64.tar && \
          rm -rf /opt/lcm-64.tar" \
   --run="gunzip  -c  lcm-core.tar.gz  |  tar  xf  -" \
   --run="rm -rf lcm-core.tar.gz" \
   --workdir=/opt/${toolName}-${toolVersion}/.lcmodel/basis-sets \
   --run="curl -o /opt/${toolName}-${toolVersion}/.lcmodel/basis-sets/3t.zip http://www.s-provencher.com/pub/LCModel/3t.zip && \
         unzip /opt/${toolName}-${toolVersion}/.lcmodel/basis-sets/3t.zip && \
         rm -rf /opt/${toolName}-${toolVersion}/.lcmodel/basis-sets/3t.zip" \
   --run="curl -o /opt/${toolName}-${toolVersion}/.lcmodel/basis-sets/1.5t.zip http://www.s-provencher.com/pub/LCModel/1.5t.zip && \
         unzip /opt/${toolName}-${toolVersion}/.lcmodel/basis-sets/1.5t.zip && \
         rm -rf /opt/${toolName}-${toolVersion}/.lcmodel/basis-sets/1.5t.zip" \
   --run="curl -o /opt/${toolName}-${toolVersion}/.lcmodel/basis-sets/7t.zip http://www.s-provencher.com/pub/LCModel/7t.zip && \
         unzip /opt/${toolName}-${toolVersion}/.lcmodel/basis-sets/7t.zip && \
         rm -rf /opt/${toolName}-${toolVersion}/.lcmodel/basis-sets/7t.zip" \
   --run="curl -o /opt/${toolName}-${toolVersion}/.lcmodel/basis-sets/9.4t.zip http://www.s-provencher.com/pub/LCModel/9.4t.zip && \
         unzip /opt/${toolName}-${toolVersion}/.lcmodel/basis-sets/9.4t.zip && \
         rm -rf /opt/${toolName}-${toolVersion}/.lcmodel/basis-sets/9.4t.zip" \
   --run="curl -o /opt/${toolName}-${toolVersion}/.lcmodel/basis-sets/basisset_LCModel.zip https://www.ismrm.org/workshops/Spectroscopy16/mrs_fitting_challenge/basisset_LCModel.zip && \
         unzip /opt/${toolName}-${toolVersion}/.lcmodel/basis-sets/basisset_LCModel.zip && \
         rm -rf /opt/${toolName}-${toolVersion}/.lcmodel/basis-sets/basisset_LCModel.zip" \
   --run="curl -o /opt/${toolName}-${toolVersion}/.lcmodel/basis-sets/RawBasis_for_sLASERSiemens_TE_20_BW_4000_NPts_2048.zip http://juchem.bme.columbia.edu/sites/default/files/2021-01/RawBasis_for_sLASERSiemens_TE_20_BW_4000_NPts_2048.zip && \
         unzip /opt/${toolName}-${toolVersion}/.lcmodel/basis-sets/RawBasis_for_sLASERSiemens_TE_20_BW_4000_NPts_2048.zip && \
         rm -rf /opt/${toolName}-${toolVersion}/.lcmodel/basis-sets/RawBasis_for_sLASERSiemens_TE_20_BW_4000_NPts_2048.zip" \
   --run="curl -o /opt/${toolName}-${toolVersion}/.lcmodel/basis-sets/RawBasis_for_sLASERSiemens_TE_20_BW_2500_NPts_1024.zip http://juchem.bme.columbia.edu/sites/default/files/2021-01/RawBasis_for_sLASERSiemens_TE_20_BW_2500_NPts_1024.zip && \
         unzip /opt/${toolName}-${toolVersion}/.lcmodel/basis-sets/RawBasis_for_sLASERSiemens_TE_20_BW_2500_NPts_1024.zip && \
         rm -rf /opt/${toolName}-${toolVersion}/.lcmodel/basis-sets/RawBasis_for_sLASERSiemens_TE_20_BW_2500_NPts_1024.zip" \
   --copy license  /opt/${toolName}-${toolVersion}/.lcmodel/license \
   --workdir=/opt/datasets \
   --run="curl -o /opt/datasets/testdata.rar https://zenodo.org/record/3904443/files/Spectra_hippocampus%28rat%29_TE02.rar?download=1 && \
          unrar x /opt/datasets/testdata.rar  && \
          rm -rf /opt/datasets/testdata.rar" \
   --run="curl -o /opt/${toolName}-${toolVersion}/manual.pdf http://www.lcmodel.com/pub/LCModel/manual/manual.pdf" \
   --copy setup_lcmodel.sh  /opt/${toolName}-${toolVersion}/.lcmodel/bin \
   --workdir /opt/${toolName}-${toolVersion}/.lcmodel/profiles/1/control-defaults \
   --copy controlfiledefault  /opt/${toolName}-${toolVersion}/.lcmodel/profiles/1/control-defaults/controlfiledefault \
   --copy gui-defaults  /opt/${toolName}-${toolVersion}/.lcmodel/profiles/1/gui-defaults \
   --run="chmod a+rwx /opt/${toolName}-${toolVersion} -R" \
   --env DEPLOY_PATH=/opt/${toolName}-${toolVersion}/.lcmodel/bin/:/opt/${toolName}-${toolVersion}/.lcmodel/ \
   --env PATH=/opt/${toolName}-${toolVersion}/.lcmodel/bin/:/opt/${toolName}-${toolVersion}/.lcmodel/:'$PATH' \
   --copy README.md /README.md \
  > ${imageName}.${neurodocker_buildExt}

if [ "$1" != "" ]; then
   ./../main_build.sh
fi