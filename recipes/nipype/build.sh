#!/usr/bin/env bash
set -e

export toolName='nipype'
export toolVersion='1.8.5' #https://pypi.org/project/nipype/
export GO_VERSION="1.19" #https://go.dev/dl/
export SINGULARITY_VERSION="3.10.2" #https://github.com/sylabs/singularity
export OS=linux 
export ARCH=amd64
export MATLAB_VERSION=R2019b
export MCR_VERSION=v97
export MCR_UPDATE=9
export SPM_VERSION=12
export SPM_REVISION=r7771 #https://www.fil.ion.ucl.ac.uk/spm/download/restricted/utopia/dev/


if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

yes | pip uninstall neurodocker

source ../main_setup.sh

# echo "installing development repository of neurodocker:"
# yes | pip uninstall neurodocker
# pip install --no-cache-dir https://github.com/NeuroDesk/neurodocker/tarball/mcr-bug --upgrade
# --matlabmcr version=2019b install_path=/opt/mcr  \
# doesn't work in Ubuntu 22.04 because of missing package multiarch-support -> bug in Neurodocker


neurodocker generate ${neurodocker_buildMode} \
   --base-image ubuntu:22.04 \
   --pkg-manager apt \
   --env DEBIAN_FRONTEND=noninteractive \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir -p ${mountPointList}" \
   --env GOPATH='$HOME'/go \
   --env PATH='$PATH':/usr/local/go/bin:${GOPATH}/bin:/opt/spm12 \
   --matlabmcr version=2019b install_path=/opt/mcr  \
   --install wget curl libglib2.0-dev ca-certificates build-essential libseccomp-dev pkg-config squashfs-tools cryptsetup \
   --run="wget https://dl.google.com/go/go$GO_VERSION.$OS-$ARCH.tar.gz \
    && tar -C /usr/local -xzvf go$GO_VERSION.$OS-$ARCH.tar.gz \
    && rm go$GO_VERSION.$OS-$ARCH.tar.gz \
    && mkdir -p $GOPATH/src/github.com/sylabs \
    && cd $GOPATH/src/github.com/sylabs \
    && wget https://github.com/sylabs/singularity/releases/download/v${SINGULARITY_VERSION}/singularity-ce-${SINGULARITY_VERSION}.tar.gz \
    && tar -xzvf singularity-ce-${SINGULARITY_VERSION}.tar.gz \
    && cd singularity-ce-${SINGULARITY_VERSION} \
    && ./mconfig --without-suid --prefix=/usr/local/singularity \
    && make -C builddir \
    && make -C builddir install \
    && cd .. \
    && rm -rf singularity-ce-${SINGULARITY_VERSION} \
    && rm -rf /usr/local/go $GOPATH \
    && ln -s /usr/local/singularity/bin/singularity /bin/" \
   --miniconda version=latest \
      conda_install="python=3.9 nipype=${toolVersion} traits scipy scikit-learn scikit-image jupyter nb_conda_kernels h5py seaborn numpy" \
      pip_install="osfclient pybids" \
   --install xdg-utils python-pyqt5.qwt-doc unzip git apt-transport-https ca-certificates coreutils \
      curl gnome-keyring gnupg libnotify4 wget libnss3 libxkbfile1 libsecret-1-0 libgtk-3-0 libxss1 libgbm1 libxshmfence1 libasound2 \
       cryptsetup squashfs-tools lua-bit32 lua-filesystem lua-json lua-lpeg lua-posix lua-term lua5.2 lmod imagemagick less nano tree \
       gcc graphviz libzstd1 zlib1g-dev zip build-essential uuid-dev libgpgme-dev libseccomp-dev pkg-config openjdk-8-jre dbus-x11 \
   --env MATLAB_VERSION=$MATLAB_VERSION \
   --env MCR_VERSION=$MCR_VERSION \
   --env MCR_UPDATE=$MCR_UPDATE \
   --env SPM_VERSION=$SPM_VERSION \
   --env SPM_REVISION=r7771 \
   --env MCR_INHIBIT_CTF_LOCK=1 \
   --env SPM_HTML_BROWSER=0 \
   --run="wget -O vscode.deb 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64' \
      && apt install ./vscode.deb  \
      && rm -rf ./vscode.deb" \
   --workdir /opt \
   --run="code --extensions-dir=/opt/vscode-extensions --user-data-dir=/opt/vscode-data --install-extension ms-python.python \
    && code --extensions-dir=/opt/vscode-extensions --user-data-dir=/opt/vscode-data --install-extension ms-python.vscode-pylance \
    && code --extensions-dir=/opt/vscode-extensions --user-data-dir=/opt/vscode-data --install-extension ms-toolsai.jupyter \
    && code --extensions-dir=/opt/vscode-extensions --user-data-dir=/opt/vscode-data --install-extension ms-toolsai.jupyter-keymap \
    && code --extensions-dir=/opt/vscode-extensions --user-data-dir=/opt/vscode-data --install-extension ms-toolsai.jupyter-renderers" \
   --env DONT_PROMPT_WSL_INSTALL=1 \
   --copy README.md /README.md \
   --copy code /usr/local/sbin/ \
   --run="chmod a+x /usr/local/sbin/code" \
   --run="wget --no-check-certificate --progress=bar:force -P /opt https://www.fil.ion.ucl.ac.uk/spm/download/restricted/bids/spm${SPM_VERSION}_${SPM_REVISION}_Linux_${MATLAB_VERSION}.zip \
      && unzip -q /opt/spm${SPM_VERSION}_${SPM_REVISION}_Linux_${MATLAB_VERSION}.zip -d /opt \
      && rm -f /opt/spm${SPM_VERSION}_${SPM_REVISION}_Linux_${MATLAB_VERSION}.zip" \
   --env LD_LIBRARY_PATH=/opt/mcr/${MCR_VERSION}/runtime/glnxa64:/opt/mcr/${MCR_VERSION}/bin/glnxa64:/opt/mcr/${MCR_VERSION}/sys/os/glnxa64:/opt/mcr/${MCR_VERSION}/sys/opengl/lib/glnxa64:/opt/mcr/${MCR_VERSION}/extern/bin/glnxa64 \
   --run="/opt/spm${SPM_VERSION}/spm${SPM_VERSION} function exit \
      && chmod +x /opt/spm${SPM_VERSION}/*" \
   --env XAPPLRESDIR=/opt/mcr/${MCR_VERSION}/x11/app-defaults \
   --env DEPLOY_BINS=code:python \
   --copy module.sh /usr/share/ \
   --user neuro \
 > ${imageName}.${neurodocker_buildExt}


if [ "$1" != "" ]; then
   ./../main_build.sh
fi

# vscode needs /run bind mounted to work!!!!

