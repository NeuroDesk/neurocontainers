#!/usr/bin/env bash
set -e

# this template file builds datalad and is then used as a docker base image for layer caching + it contains examples for various things like github install, curl, ...
export toolName='deepsif'
export toolVersion='0.0.1' #the version number cannot contain a "-" - try to use x.x.x notation always
# Don't forget to update version change in README.md!!!!!
# toolName or toolVersion CANNOT contain capital letters or dashes or underscores (Docker registry does not accept this!)

# !!!!
# You can test the container build locally by running `bash build.sh -ds`
# !!!!


if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base-image debian:11   \
   --pkg-manager apt   \
   --env DEBIAN_FRONTEND=noninteractive  \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll"  \
   --run="mkdir -p ${mountPointList}" \
   --install opts='--quiet' midori xdg-utils pkg-config software-properties-common libstdc++6 gcc-10-base python3-pyqt5 unzip git apt-transport-https ca-certificates coreutils curl gnome-keyring gnupg libnotify4 wget libnss3 libxkbfile1 libsecret-1-0 libgtk-3-0  libgcc1  libc6 libxss1 libgbm1 libxshmfence1 libasound2 libglu1-mesa libgl1-mesa-dri mesa-utils libgl1-mesa-glx binutils \
   --run="wget -q https://developer.download.nvidia.com/compute/cuda/repos/debian11/x86_64/cuda-keyring_1.0-1_all.deb \
          && dpkg -i cuda-keyring_1.0-1_all.deb \
          && rm cuda-keyring_1.0-1_all.deb"\
   --run="apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/debian11/x86_64/7fa2af80.pub"\
   --run="add-apt-repository 'deb https://developer.download.nvidia.com/compute/cuda/repos/debian11/x86_64/ /'"\
   --run="add-apt-repository contrib"\
   --install opts='--quiet' cuda-11-5 nsight-compute-2022.2.0 \
   --run="wget -q https://developer.download.nvidia.com/compute/redist/cudnn/v8.3.0/cudnn-11.5-linux-x64-v8.3.0.98.tgz \
          && tar -xvf cudnn-11.5-linux-x64-v8.3.0.98.tgz \
          && rm cudnn-11.5-linux-x64-v8.3.0.98.tgz \
          && chmod a+r cuda/include/cudnn*.h cuda/lib64/libcudnn* \
          && ln -s cuda/include/cudnn*.h /usr/local/cuda/include \
          && cp -P cuda/lib64/libcudnn* /usr/local/cuda/lib64"\
   --miniconda \
        version=4.7.12 \
        env_name=base \
   --run="conda install -c conda-forge mamba=0.24.0 "\
   --run="mamba create --override-channels --channel=conda-forge --name=${toolName}-${toolVersion} python=3.7 mne nomkl numba scipy numpy networkx scikit-learn cython pip numexpr psutil psycopg2 pytables scikit-image simplejson cherrypy docutils werkzeug matplotlib-base h5py"\
   --run-bash=". activate ${toolName}-${toolVersion} \
        && pip3 install --no-cache-dir torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu113 \
        && rm -rf ~/.cache/pip/*"\
   --run-bash=". activate ${toolName}-${toolVersion} \
        && pip3 install --no-cache-dir formencode cfflib jinja2 nibabel sqlalchemy sqlalchemy-migrate allensdk tvb-gdist typing BeautifulSoup4 subprocess32 flask-restplus python-keycloak mako pybids tvb-library tvb-framework\
        && rm -rf ~/.cache/pip/*"\
   --env DONT_PROMPT_WSL_INSTALL=1 \
   --workdir=/opt/ \
   --run="curl -fsSL https://github.com/mne-tools/mne-bids-pipeline/archive/refs/heads/main.tar.gz | tar xz \
            && chmod a+rwx /opt/mne-bids-pipeline-main -R" \
   --env LD_LIBRARY_PATH='$LD_LIBRARY_PATH':'$CONDA_PREFIX'/lib/ \
   --env LD_LIBRARY_PATH='$LD_LIBRARY_PATH':/usr/local/cuda/lib64   \
   --copy README.md /README.md                          \
   --env XDG_RUNTIME_DIR=/neurodesk-storage \
   --env RUNLEVEL=3\
   --user neuro \
  > ${imageName}.${neurodocker_buildExt}           

if [ "$1" != "" ]; then
   ./../main_build.sh
fi
