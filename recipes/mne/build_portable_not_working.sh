#!/usr/bin/env bash
set -e

# this template file builds itksnap and is then used as a docker base image for layer caching
export toolName='mne'
export toolVersion='0.23.4'
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
   --copy mne-pinned.yml /opt/mne-pinned.yml \
   --miniconda version=latest \
      env_name=${toolName}-${toolVersion} \
      env_exists=false \
      yaml_file=/opt/mne-pinned.yml \
      pip_install="osfclient" \
   --install midori xdg-utils python-pyqt5 unzip git apt-transport-https ca-certificates coreutils curl gnome-keyring gnupg libnotify4 wget libnss3 libxkbfile1 libsecret-1-0 libgtk-3-0 libxss1 libgbm1 libxshmfence1 libasound2 \
   --env DONT_PROMPT_WSL_INSTALL=1 \
   --run="wget -O /opt/vscode.tar.gz -q 'https://code.visualstudio.com/sha/download?build=stable&os=linux-x64' \
      && mkdir /opt/vscode \
      && tar -xzf /opt/vscode.tar.gz -C /opt/vscode --strip-components 1  \
      && rm -rf /opt/vscode.tar.gz \
      && mkdir /opt/vscode/data \
      && chmod a+rwx /opt/vscode/data -R" \
   --copy README.md /README.md \
   --run="ln -s /opt/vscode/code /usr/local/sbin/" \
   --run="chmod a+x /opt/vscode/code" \
   --env DEPLOY_BINS=code \
 > ${imageName}.${neurodocker_buildExt}
   # --run="code --no-sandbox --install-extension ms-python.python \
   #  && code --no-sandbox --install-extension ms-python.vscode-pylance \
   #  && code --no-sandbox --install-extension ms-toolsai.jupyter \
   #  && code --no-sandbox --install-extension ms-toolsai.jupyter-keymap \
   #  && code --no-sandbox --install-extension ms-toolsai.jupyter-renderers" \
   # --user neuro \

   # --run="wget -O vscode.deb 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64' \
   #    && apt install ./vscode.deb  \
   #    && rm -rf ./vscode.deb" \
      # conda_install="python=3.8 jupyter mne=${toolVersion} mne-bids mnelab nb_conda_kernels pytables h5py seaborn statsmodels pybv scikit-learn pyxdf pyEDFlib neurokit2" \
      # pip_install="osfclient" \


if [ "$1" != "" ]; then
   ./../main_build.sh
fi

# vscode needs /run bind mounted to work!!!!
