#!/usr/bin/env bash
set -e

export toolName='xcpd'
export toolVersion='0.10.5'

export DEBIAN_FRONTEND=noninteractive

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base-image pennlinc/xcp_d:0.10.5 \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir -p ${mountPointList}" \
   --run="apt-get update -qq && \
         apt-get install -y -q --no-install-recommends \
         wget \
         curl \
         ca-certificates \
         git \
         python3-pip \
         libgomp1 \
         python3-dev \
         build-essential \
         libfontconfig1 \
         libfreetype6 \
         libglib2.0-0 \
         && rm -rf /var/lib/apt/lists/*" \
--run="mkdir -p /usr/lib/x86_64-linux-gnu/ && \
        cd /tmp && \
        wget -q http://mirrors.kernel.org/ubuntu/pool/main/libp/libpng/libpng12-0_1.2.54-1ubuntu1.1_amd64.deb && \
        dpkg-deb -x libpng12-0_1.2.54-1ubuntu1.1_amd64.deb . && \
        cp -r ./lib/x86_64-linux-gnu/libpng12.so.0* /usr/lib/x86_64-linux-gnu/ && \
        ldconfig && \
        rm -f libpng12-0_1.2.54-1ubuntu1.1_amd64.deb" \
   --env DEPLOY_BINS=xcp_d \
   --copy README.md /README.md \
   --copy test.sh /test.sh \
   --workdir /tmp \
   > ${imageName}.${neurodocker_buildExt}

if [ "$1" != "" ]; then
   ./../main_build.sh
fi