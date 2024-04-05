#!/usr/bin/env bash
set -e

export toolName='julia'
export toolVersion='1.9.4'
export releaseVersion='1.9'
# Don't forget to update version change in README.md!!!!!

if [ "$1" != "" ]; then
   echo "Entering Debug mode"
   export debug=$1
fi

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base-image ubuntu:22.04 \
   --pkg-manager apt \
   --env DEBIAN_FRONTEND=noninteractive \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir -p ${mountPointList}" \
   --install xdg-utils unzip git apt-transport-https ca-certificates coreutils \
      curl gnome-keyring gnupg libnotify4 wget libnss3 libxkbfile1 libsecret-1-0 libgtk-3-0 libxss1 libgbm1 libxshmfence1 libasound2 \
      lmod less nano tree strace libx11-xcb1 \
      gcc graphviz libzstd1 zlib1g-dev zip build-essential uuid-dev libgpgme-dev libseccomp-dev pkg-config \
   --run="wget -O vscode.deb 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64' \
      && apt install ./vscode.deb  \
      && rm -rf ./vscode.deb" \
   --workdir /opt \
   --run="wget https://julialang-s3.julialang.org/bin/linux/x64/${releaseVersion}/julia-${toolVersion}-linux-x86_64.tar.gz \
      && tar zxvf julia-${toolVersion}-linux-x86_64.tar.gz \
      && rm -rf julia-${toolVersion}-linux-x86_64.tar.gz \
      && ln -s /opt/julia-${toolVersion} /opt/julia-latest" \
   --run="code --extensions-dir=/opt/vscode-extensions --user-data-dir=/opt/vscode-data --install-extension julialang.language-julia \
      && code --extensions-dir=/opt/vscode-extensions --user-data-dir=/opt/vscode-data --install-extension KorbinianEckstein.niivue \
      && rm -rf /opt/vscode-data/CachedExtensionVSIXs/" \
   --env PATH='$PATH':/opt/julia-${toolVersion}/bin \
   --workdir="/opt" \
   --copy install_packages.jl "/opt" \
   --env JULIA_DEPOT_PATH="/opt/julia_depot" \
   --run="julia install_packages.jl" \
   --env JULIA_DEPOT_PATH="~/.julia:/opt/julia_depot" \
   --copy README.md /README.md \
   --copy code /usr/local/sbin/ \
   --run="chmod a+x /usr/local/sbin/code" \
   --run="chmod a+rwx /opt/vscode-extensions/ -R" \
   --run="chmod a+rwx /opt/vscode-data -R" \
   --env DEPLOY_BINS="code:julia" \
   --copy module.sh /usr/share/ \
   --user neuro \
   >${imageName}.${neurodocker_buildExt}

if [ "$1" != "" ]; then
   ./../main_build.sh
fi
