#!/usr/bin/env bash
set -e

export toolName='rstudio'
export toolVersion='1.4.1106'
# Don't forget to update version change in README.md!!!!!

# based on this, but no CUDA: https://github.com/Characterisation-Virtual-Laboratory/CharacterisationVL-Software/blob/master/R/Singularity.R_4.0.5

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug="true"
fi

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base-image ubuntu:20.04 \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir ${mountPointList}" \
   --workdir /opt \
   --install software-properties-common \
   --run="apt-add-repository -y 'deb http://us.archive.ubuntu.com/ubuntu/ focal main restricted'" \
   --run="apt-add-repository -y 'deb http://us.archive.ubuntu.com/ubuntu/ focal-updates main restricted'" \
   --run="apt-add-repository -y 'deb http://us.archive.ubuntu.com/ubuntu/ focal universe'" \
   --run="apt-add-repository -y 'deb http://us.archive.ubuntu.com/ubuntu/ focal-updates universe'" \
   --env LC_ALL=en_AU.UTF-8 \
   --env LANGUAGE=en_AU.UTF-8 \
   --env DEBIAN_FRONTEND=noninteractive \
   --install locales \
   --run="locale-gen en_AU.UTF-8" \
   --install wget ubuntu-desktop vim software-properties-common git cmake mesa-utils sudo build-essential gpg-agent \
   --install python3-pip python3-pyqt5 pyqt5-dev python3-tk python3-pandas python3-fire \
   --install dirmngr gnupg apt-transport-https ca-certificates software-properties-common \
   --run="apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9" \
   --install r-base gdebi-core libssl-dev curl libxml2-dev libcurl4-openssl-dev \
   --workdir /opt \
   --run="wget https://download1.rstudio.org/desktop/bionic/amd64/rstudio-1.4.1106-amd64.deb" \
   --install libclang-dev libpq5 \
   --run="gdebi -q -n /opt/rstudio-1.4.1106-amd64.deb" \
   --run="rm -rf rstudio-1.4.1106-amd64.deb" \
   --copy dependencies.R /opt \
   --run="Rscript /opt/dependencies.R" \
   --env DEPLOY_PATH=/opt/${toolName}-${toolVersion}/bin/ \
   --env PATH=${PATH}:/usr/local/cuda/bin \
   --env LD_LIBRARY_PATH=/usr/local/cuda/lib64/stubs:/usr/local/cuda/lib64/:/usr/local/cuda/lib:${LD_LIBRARY_PATH} \
   --user=neuro \
  > ${imageName}.${neurodocker_buildExt}
  


if [ "$debug" = "true" ]; then
   ./../main_build.sh
fi


   