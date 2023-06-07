#!/usr/bin/env bash
set -e

export toolName='itksnap'
export toolVersion='4.0.1'

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base-image fedora:38 \
   --pkg-manager yum \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir -p ${mountPointList}" \
   --install curl ca-certificates xcb-util-renderutil xcb-util-keysyms xcb-util-wm xcb-util-image libxkbcommon-x11 unzip dbus-libs libX11 libglvnd-glx libglvnd-opengl libxkbcommon libglvnd-egl fontconfig \
   --run="curl -fsSL -o /example_data.zip https://www.nitrc.org/frs/download.php/750/MRI-crop.zip  \
         && unzip /example_data.zip \
         && rm /example_data.zip" \
   --workdir /opt/${toolName}-${toolVersion} \
   --run="curl -fsSL --retry 5 https://ixpeering.dl.sourceforge.net/project/itk-snap/itk-snap/4.0.1/itksnap-4.0.1-20230320-Linux-gcc64.tar.gz | tar -xz --strip-components=1 -C /opt/${toolName}-${toolVersion}" \
   --env PATH='$PATH':/opt/${toolName}-${toolVersion}/bin/ \
   --env DEPLOY_PATH=/opt/${toolName}-${toolVersion}/bin/ \
   --env DEPLOY_ENV_TEST=/opt/fsl-${toolVersion} \
   --env QT_DEBUG_PLUGINS=1 \
   --copy README.md /README.md \
  > ${imageName}.${neurodocker_buildExt}
   # --entrypoint "/opt/${toolName}-${toolVersion}/bin/itksnap /MRIcrop-orig.gipl" \

if [ "$1" != "" ]; then
   ./../main_build.sh
fi


   
