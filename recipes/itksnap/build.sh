#!/usr/bin/env bash
set -e

export toolName='itksnap'
export toolVersion='4.0.2'

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

if [ -z "$TINYRANGE" ]; then
   neurodocker generate ${neurodocker_buildMode} \
      --base-image ubuntu:22.04 \
      --pkg-manager apt \
      --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
      --run="chmod +x /usr/bin/ll" \
      --run="mkdir -p ${mountPointList}" \
      --install curl ca-certificates unzip  mlocate binutils libqt5gui5 libopengl0 \
      --run="curl -fsSL -o /example_data.zip https://www.nitrc.org/frs/download.php/750/MRI-crop.zip  \
            && unzip /example_data.zip \
            && rm /example_data.zip" \
      --workdir /opt/${toolName}-${toolVersion} \
      --env QT_QPA_PLATFORM="xcb" \
      --run="curl -fsSL --retry 5 https://ixpeering.dl.sourceforge.net/project/itk-snap/itk-snap/${toolVersion}/itksnap-${toolVersion}-Linux-gcc64.tar.gz | tar -xz --strip-components=1 -C /opt/${toolName}-${toolVersion}" \
      --env DEPLOY_PATH=/opt/${toolName}-${toolVersion}/bin/ \
      --env PATH='$PATH':/opt/${toolName}-${toolVersion}/bin/ \
      --run="find /opt/itksnap-4.0.2/ -name '*.so.*' | xargs strip --remove-section=.note.ABI-tag" \
      --copy README.md /README.md \
   > ${imageName}.${neurodocker_buildExt}
else
   echo "EXPERIMENTAL: using tinyrange"

   $TINYRANGE login \
      --size xl \
      --pkg ubuntu \
      --pkg pkg:unzip,mlocate,binutils,libqt5gui5,libopengl0 \
      --file https://www.nitrc.org/frs/download.php/750/MRI-crop.zip \
      --file https://ixpeering.dl.sourceforge.net/project/itk-snap/itk-snap/${toolVersion}/itksnap-${toolVersion}-Linux-gcc64.tar.gz \
      --exec "set -ex; \
         (cd /; unzip /root/MRI-crop.zip); \
         rm /root/MRI-crop.zip; \
         mkdir -p /opt/${toolName}-${toolVersion}; \
         tar -xz --strip-components=1 -C /opt/${toolName}-${toolVersion} -f /root/itksnap-${toolVersion}-Linux-gcc64.tar.gz; \
         find /opt/${toolName}-${toolVersion}/ -name '*.so.*' | xargs strip --remove-section=.note.ABI-tag" \
      --pull-snapshot itksnap.tar.gz

   neurodocker generate ${neurodocker_buildMode} \
      --base-image ubuntu:22.04 \
      --pkg-manager apt \
      --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
      --run="chmod +x /usr/bin/ll" \
      --run="mkdir -p ${mountPointList}" \
      --add ./itksnap.tar.gz / \
      --env QT_QPA_PLATFORM="xcb" \
      --env DEPLOY_PATH=/opt/${toolName}-${toolVersion}/bin/ \
      --env PATH='$PATH':/opt/${toolName}-${toolVersion}/bin/ \
      --copy README.md /README.md \
   > ${imageName}.${neurodocker_buildExt}
fi

# 

# needed for centos, but libcurl error: libX11 libglvnd-glx libglvnd-opengl libxkbcommon libglvnd-egl fontconfig dbus-libs

 #  --env QT_QPA_PLATFORM="xcb" forces xcb under wayland - this was otherwise causing a library error

# This is to fix qt library error in centos 7:
# --run="find /opt/itksnap-4.0.2/ -name '*.so' | xargs strip --remove-section=.note.ABI-tag" \
# https://github.com/microsoft/WSL/issues/3023

if [ "$1" != "" ]; then
   ./../main_build.sh
fi


   
