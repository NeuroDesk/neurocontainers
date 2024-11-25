export toolName='bidsappaa'
# toolName or toolVersion CANNOT contain capital letters or dashes or underscores (Docker registry does not accept this!)

export toolVersion='0.2.0' 
# the version number cannot contain a "-" - try to use x.x.x notation always
# https://hub.docker.com/r/bids/aa/tags

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base-image bids/${toolName:7}:v${toolVersion} \
   --env DEBIAN_FRONTEND=noninteractive \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir -p ${mountPointList}" \
   --env PATH='$PATH':/opt/bin \
   --env DEPLOY_PATH=/opt/automaticanalysis5:/opt/bin:/opt/fsl/bin:/opt/freesurfer/bin \
   --run="chmod +x /opt/automaticanalysis5/run_automaticanalysis.sh" \
   --copy README.md /README.md \
   --entrypoint bash \
  > ${imageName}.${neurodocker_buildExt}


if [ "$1" != "" ]; then
   ./../main_build.sh
fi
