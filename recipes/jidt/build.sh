#!/usr/bin/env bash
set -e

#installs jidt + python + rstudio. 
  #other data analysis environments that you may want to use 
  #e.g. matlab, julia, clojure are missing.
# https://lizier.me/joseph/software/jidt/download.php?file=infodynamics-dist-1.6.zip
export downloadLink='https://lizier.me/joseph/software/jidt/download.php?file=infodynamics-dist-1.6.zip'
export toolName='jidt'
export toolVersion='1.6'
export rstudioToolName='rstudio'
export rstudioToolVersion='2022.07.2'
export rstudioAdditionalVersion='576'
#When updating this version you also need to update the MONAILabel plugin version (line 31)!
# Don't forget to update version change in README.md!!!!!

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

export DOCKER_BUILDKIT=0
export COMPOSE_DOCKER_CLI_BUILD=0

neurodocker generate ${neurodocker_buildMode} \
   --base-image ubuntu:22.04 \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir ${mountPointList}" \
   --workdir /opt/${toolName}-${toolVersion}/ \
   --install curl \
   --install unzip \
   --run="curl -s -k --retry 5 ${downloadLink} -o infodynamics-dist-1.6.zip" \
   --run="unzip infodynamics-dist-1.6.zip -d infodynamics-dist-1.6" \
   --install openjdk-8-jre \
    --run="rm -rf infodynamics-dist-1.6.zip" \
   --miniconda version=latest \
      conda_install="python=3.9 scipy scikit-learn matplotlib jupyter seaborn numpy pandas" \
      pip_install="osfclient jpype1" \
   --env DEPLOY_PATH=/opt/${toolName}-${toolVersion}/:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
   --copy README.md /README.md \
   --workdir /opt \
   --install locales software-properties-common \
   --env LC_ALL=en_AU.UTF-8 \
   --env LANGUAGE=en_AU.UTF-8 \
   --env DEBIAN_FRONTEND=noninteractive \
    --run="locale-gen en_AU.UTF-8" \
   --install wget ubuntu-desktop vim software-properties-common git cmake mesa-utils sudo build-essential \
      python3-pip python3-pyqt5 pyqt5-dev python3-tk python3-pandas python3-fire \
      dirmngr gnupg apt-transport-https ca-certificates software-properties-common \
      r-base gdebi-core libssl-dev curl libxml2-dev libcurl4-openssl-dev libharfbuzz-dev libfribidi-dev \
      libclang-dev libpq5 libfftw3-dev gpg-agent \
      libgfortran-9-dev libblas-dev libblas64-dev liblapack-dev gfortran libudunits2-dev r-cran-ncdf4 \
      libgdal-dev libproj-dev libgeos-dev libudunits2-dev libnode-dev libcairo2-dev libnetcdf-dev \
   --run="wget https://download1.rstudio.org/desktop/jammy/amd64/rstudio-${rstudioToolVersion}-${rstudioAdditionalVersion}-amd64.deb" \
   --run="gdebi -q -n /opt/rstudio-${rstudioToolVersion}-${rstudioAdditionalVersion}-amd64.deb" \
   --run="rm -rf rstudio-${rstudioToolVersion}-${rstudioAdditionalVersion}-amd64.deb" \
   --copy dependencies.R /opt \
   --run="Rscript /opt/dependencies.R" \
   --env DEPLOY_BINS=Rscript:rstudio \
   --env PATH=${PATH}:/usr/local/cuda/bin \
   --env LD_LIBRARY_PATH=/usr/local/cuda/lib64/stubs:/usr/local/cuda/lib64/:/usr/local/cuda/lib:${LD_LIBRARY_PATH} \
  > ${toolName}_${toolVersion}.Dockerfile

if [ "$1" != "" ]; then
   ./../main_build.sh
fi