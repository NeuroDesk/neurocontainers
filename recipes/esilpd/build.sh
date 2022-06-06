#!/usr/bin/env bash
set -e

# this template file builds datalad and is then used as a docker base image for layer caching + it contains examples for various things like github install, curl, ...
export toolName='esilpd'
export toolVersion=0.0.1 #the version number cannot contain a "-" - try to use x.x.x notation always
# export freesurferVersion=7.2.0
export cudaversion=11.3.0
export cudnnversion=8.2.1.32
# Don't forget to update version change in README.md!!!!!
# toolName or toolVersion CANNOT contain capital letters or dashes or underscores (Docker registry does not accept this!)


if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

source ../main_setup.sh

###########################################################################################################################################
# 
# IF POSSIBLE, PLEASE DOCUMENT EACH ARGUMENT PROVIDED TO NEURODOCKER. USE THE `# your comment` NOTATION THAT ALLOWS MID-COMMAND COMMENTS
# NOTE 1: THE QUOTES THAT ENCLOSE EACH COMMENT MUST BE BACKQUOTES (`). OTHER QUOTES WON'T WORK!
# NOTE 2: THE BACKSLASH (\) AT THE END OF EACH LINE MUST FOLLOW THE COMMENT. A BACKSLASH BEFORE THE COMMENT WON'T WORK!
# if neurodocker not in path or in ~/.local.bin add these lines:
# 
# if [ -d "$HOME/.local/bin" ] ; then
#     PATH="$HOME/.local/bin:$PATH"
# fi
# # 
#    --run="wget --quiet https://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/${freesurferVersion}/freesurfer-linux-ubuntu18_amd64-${freesurferVersion}.tar.gz && tar -zxpf freesurfer-linux-ubuntu18_amd64-${freesurferVersion}.tar.gz -C /usr/local" `# might take hours to downlaod the freesurfer file`\
#    --run="rm freesurfer-linux-ubuntu18_amd64-${freesurferVersion}.tar.gz"\
#    --env SUBJECTS_DIR="/usr/local/freesurfer/subjects" \
#    --env FREESURFER_HOME="/usr/local/freesurfer"\
# if pip get error for low version, upgrade user pip by "python3 -m pip install --user --upgrade pip"
# do not bash build.sh -ds on weiner cause the python version on server is 3.6 while neurodesk require >=3.7
# pytorch 1.10 cuda/cudnn11.3
# miniconda: python 3.8 mne 1.0.0 with other dependency
# TODO: 
#    --run="echo 'k.lou@uq.edu.au\n> 59781\n>*Cvh5NaJ7ls06\n>FSdH6GCgQL/rA' >> ~/.license"\
   # --run="export FS_LICENSE=~/.license "\
# some source code from github
# some sample data from github
# future: try tvb 
   # --run="wget https://developer.nvidia.com/compute/machine-learning/cudnn/secure/8.2.1.32/11.3_06072021/cudnn-11.3-linux-x64-v8.2.1.32.tgz"\
   # --run="dpkg -i cudnn-11.3-linux-x64-v8.2.1.32.tgz && rm cudnn-11.3-linux-x64-v8.2.1.32.tgz"\
   # --run="cp cudnn-*-archive/include/cudnn*.h /usr/local/cuda/include "\
   # --run="cp -P cudnn-*-archive/lib/libcudnn* /usr/local/cuda/lib64 "\
   # --run="chmod a+r /usr/local/cuda/include/cudnn*.h /usr/local/cuda/lib64/libcudnn* "\
#########################################################################################################################################

neurodocker generate ${neurodocker_buildMode} \
   --base-image ubuntu:20.04  `#  some container images from docker hub` \
   --pkg-manager apt                                           `# desired package manager, has to match the base image (e.g. debian needs apt; centos needs yum)` \
   --env DEBIAN_FRONTEND=noninteractive                        `# this disables interactive questions during package installs` \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll"   `# define the ll command to show detailed list including hidden files`  \
   --run="chmod +x /usr/bin/ll"                         `# make ll command executable`  \
   --run="mkdir -p ${mountPointList}"                      `# create folders for singularity bind points` \
   --install wget git python3-pip tar curl unzip gnupg software-properties-common dbus-x11 libgtk2.0-0 qt5-default`# install apt-get packages` \
   --run="wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin && mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600"\
   --run="apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/3bf863cc.pub"\
   --run="add-apt-repository 'deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/ /'"\
   --run="apt-get update"\
   --run="apt-get -y install cuda-11-3"\
   --run="apt-get install libcudnn8=${cudnnversion}-1+cuda11.3"\
   --miniconda \
        version=4.7.12 \
        env_name=base \
   --run="conda install -c conda-forge mamba=0.24.0 "\
   --run="mamba create --override-channels --channel=conda-forge --name=mnetorch mne"\
   --run-bash=". activate mnetorch && pip3 install --no-cache-dir torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu113"\
   --run-bash=". activate mnetorch && pip3 install --no-cache-dir tensorflow==2.8.2 esinet osfclient scikit-image pybids seaborn argh joblib torchaudio"\
   --run="rm -rf ~/.cache/pip/*"\
   --run="wget -O vscode.deb 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64' \
   && apt install ./vscode.deb  \
   && rm -rf ./vscode.deb" \
   --workdir /opt/${toolName}-${toolVersion}/           `# create install directory` \
   --env PATH='$PATH':/usr/local/cuda/bin/ `# create install directory` \
   --env LD_LIBRARY_PATH='$LD_LIBRARY_PATH':'$CONDA_PREFIX'/lib/  `# tensorflow `\
   --env LD_LIBRARY_PATH='$LD_LIBRARY_PATH':/usr/local/cuda/lib64  `# create install directory` \
   --env PATH='$PATH':/opt/${toolName}-${toolVersion}   `# set PATH` \
   --env DEPLOY_PATH=/opt/${toolName}-latest/           `# specify a path where ALL binary files will be exposed outside the container for the module system. Never expose a directory with system commands (like /bin/ /usr/bin ...)` \
   --copy README.md /README.md                          `# include readme file in container` \
  > ${imageName}.${neurodocker_buildExt}                `# LAST COMMENT; NOT FOLLOWED BY BACKSLASH!`

if [ "$1" != "" ]; then
   ./../main_build.sh
fi
