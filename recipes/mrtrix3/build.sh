#!/usr/bin/env bash
set -e

export toolName='mrtrix3'
export toolVersion='3.0.4'
# Don't forget to update version change in README.md!!!!!
# https://github.com/MRtrix3/mrtrix3/releases/

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base-image vnmd/fsl_6.0.5.1:20221016 \
   --pkg-manager apt \
   --${toolName} version=${toolVersion} method="source" build_processes=1 \
   --ants version="2.3.4" \
   --workdir /opt/${toolName}-${toolVersion} \
   --install dbus-x11 less python3-distutils mesa-common-dev libglu1-mesa qt5-default libqt5svg5-dev wget libqt5opengl5-dev libqt5opengl5 libqt5gui5 libqt5core5a libtiff5-dev libtiff5 libfftw3-dev liblapack3 \
   --run "python3 configure" \
   --run "python3 build" \
   --run "ln -s /usr/bin/python3 /usr/bin/python" \
   --workdir /opt/acpcdetect_V2.1 \
   --run="wget https://object-store.rc.nectar.org.au/v1/AUTH_dead991e1fa847e3afcca2d3a7041f5d/build/acpcdetect_V2.1_LinuxCentOS6.7.tar.gz \
      && tar zxvf acpcdetect_V2.1_LinuxCentOS6.7.tar.gz \
      && rm -rf acpcdetect_V2.1_LinuxCentOS6.7.tar.gz" \
   --env ARTHOME=/opt/acpcdetect_V2.1/ \
   --env PATH='$PATH':/opt/acpcdetect_V2.1/bin \
   --env DEPLOY_PATH=/opt/${toolName}-${toolVersion}/bin/:/opt/acpcdetect_V2.1/bin \
   --copy README.md /README.md \
   --user=neuro \
  > ${imageName}.${neurodocker_buildExt}

if [ "$1" != "" ]; then
   ./../main_build.sh
fi
