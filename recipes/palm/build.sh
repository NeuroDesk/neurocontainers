#!/usr/bin/env bash
set -e

# this template file builds itksnap and is then used as a docker base image for layer caching
export toolName='palm'
export toolVersion='alpha119'
# Don't forget to update version change in README.md!!!!!




if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base-image ubuntu:22.04 \
   --env DEBIAN_FRONTEND=noninteractive \
   --pkg-manager apt \
   --install octave curl ca-certificates \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir ${mountPointList}" \
   --workdir /opt/${toolName}-${toolVersion}/ \
   --run="curl -fsSL --retry 5 https://s3-us-west-2.amazonaws.com/andersonwinkler/palm/palm-alpha119.tar.gz \
      | tar -xz -C /opt/${toolName}-${toolVersion}/ --strip-components 1" \
   --env DEPLOY_BINS=palm:octave \
   --env PATH='$PATH':/opt/palm-alpha119 \
   --copy README.md /README.md \
  > ${imageName}.${neurodocker_buildExt}

if [ "$1" != "" ]; then
   ./../main_build.sh
fi
