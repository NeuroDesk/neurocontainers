#!/usr/bin/env bash
set -e

export toolName='brainlifecli'
export toolVersion='1.7.0' # https://github.com/brainlife/cli & https://www.npmjs.com/package/brainlife
export NODE_MAJOR=20
# Don't forget to update version change in README.md!!!!!

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base-image ubuntu:20.04 \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --install ca-certificates curl gnupg \
   --run="mkdir -p ${mountPointList}" \
   --run="mkdir -p /etc/apt/keyrings" \
   --run="curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg" \
   --run="echo 'deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main' | tee /etc/apt/sources.list.d/nodesource.list" \
   --install nodejs \
   --run="npm install -g npm@10.2.4" \
   --run="npm install -g brainlife" \
   --env DEPLOY_BINS="bl" \
   --env PATH=/usr/local/bin:${PATH} \
   --copy README.md /README.md \
  > ${imageName}.${neurodocker_buildExt}

if [ "$1" != "" ]; then
   ./../main_build.sh
fi

