#!/usr/bin/env bash
set -e

export toolName='itksnap'
export toolVersion='3.8.0'
# Don't forget to update version change in README.md!!!!!

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug="true"
fi

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base-image ubuntu:16.04 \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir ${mountPointList}" \
   --run="curl -o /example_data.zip https://www.nitrc.org/frs/download.php/750/MRI-crop.zip " \
   --run="unzip /example_data.zip" \
   --${toolName} version=${toolVersion} \
   --entrypoint "/opt/${toolName}-${toolVersion}/bin/itksnap /MRIcrop-orig.gipl" \
   --env DEPLOY_PATH=/opt/${toolName}-${toolVersion}/bin/ \
   --user=neuro \
  > ${imageName}.${neurodocker_buildExt}

if [ "$debug" = "true" ]; then
   ./../main_build.sh
fi


   
