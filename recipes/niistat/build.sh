#!/usr/bin/env bash
set -e

# this template file builds itksnap and is then used as a docker base image for layer caching
export toolName='niistat'
export toolVersion='1.0.20191216'
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
   --install octave curl ca-certificates wget unzip liboctave-dev patch make fonts-freefont-otf \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir -p ${mountPointList}" \
   --workdir /opt/${toolName}-${toolVersion}/ \
   --run="curl -fsSL --retry 5 https://github.com/neurolabusc/NiiStat/archive/refs/tags/v${toolVersion}.tar.gz \
      | tar -xz -C /opt/${toolName}-${toolVersion}/ --strip-components 1" \
   --workdir /opt/ \
   --copy SPMinOctave.m /opt/SPMinOctave.m \
   --run="octave SPMinOctave.m" \
   --env DEPLOY_BINS=octave \
   --env PATH='$PATH':/opt/niistat-${toolVersion} \
   --copy README.md /README.md \
  > ${imageName}.${neurodocker_buildExt}

if [ "$1" != "" ]; then
   ./../main_build.sh
fi
