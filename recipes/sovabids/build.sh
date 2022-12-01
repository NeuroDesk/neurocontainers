#!/usr/bin/env bash
set -e

# this template file builds itksnap and is then used as a docker base image for layer caching
export toolName='sovabids'
export toolVersion='0.3a0'
# Don't forget to update version change in condaenv.yml AND README.md!!!!!

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base-image debian:9 \
   --pkg-manager apt \
   --env DEBIAN_FRONTEND=noninteractive \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir ${mountPointList}" \
   --install midori xdg-utils python-pyqt5 unzip git apt-transport-https ca-certificates coreutils curl gnome-keyring gnupg libnotify4 wget libnss3 libxkbfile1 libsecret-1-0 libgtk-3-0 libxss1 libgbm1 libxshmfence1 libasound2 libglu1-mesa libgl1-mesa-dri mesa-utils libgl1-mesa-glx spyder \
   --copy sovabids.yml /opt/sovabids.yml \
   --miniconda version=4.7.12 \
      env_name=base \
   --run="conda install -c conda-forge -n base mamba=0.24.0 "\
   --run="source /opt/miniconda-4.7.12/etc/profile.d/conda.sh"
   --run="conda activate sovabids"
   #--run="pip install git+https://github.com/yjmantilla/sovabids.git@v0.3-alpha bids_validator"
   --run="mamba env create --file /opt/sovabids.yml" \
   --run="wget -O vscode.deb 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64' \
      && apt install ./vscode.deb  \
      && rm -rf ./vscode.deb" \
   --run=" code --extensions-dir=/opt/vscode-extensions --user-data-dir=/opt/vscode-data --install-extension ms-python.python \
    && code --extensions-dir=/opt/vscode-extensions --user-data-dir=/opt/vscode-data --install-extension ms-python.vscode-pylance \
    && code --extensions-dir=/opt/vscode-extensions --user-data-dir=/opt/vscode-data --install-extension ms-toolsai.jupyter \
    && code --extensions-dir=/opt/vscode-extensions --user-data-dir=/opt/vscode-data --install-extension ms-toolsai.jupyter-keymap \
    && code --extensions-dir=/opt/vscode-extensions --user-data-dir=/opt/vscode-data --install-extension ms-toolsai.jupyter-renderers" \
   --env DONT_PROMPT_WSL_INSTALL=1 \
   --workdir=/opt/ \
   --run="curl -fsSL https://github.com/mne-tools/mne-bids-pipeline/archive/refs/heads/main.tar.gz | tar xz" \
   --run="chmod a+rwx /opt/mne-bids-pipeline-main -R" \
   --copy README.md /README.md \
   --copy code /usr/local/sbin/ \
   --run="chmod a+x /usr/local/sbin/code" \
   --run="chmod a+rwx /opt/vscode-extensions -R" \
   --env DEPLOY_BINS=code \
   --env XDG_RUNTIME_DIR=/neurodesktop-storage \
   --env RUNLEVEL=3\
   --user neuro \
 > ${imageName}.${neurodocker_buildExt}


if [ "$1" != "" ]; then
   ./../main_build.sh
fi

# vscode needs /run bind mounted to work!!!!
