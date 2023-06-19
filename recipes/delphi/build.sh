#!/usr/bin/env bash
set -e

# this template file builds delphi and is then used as a docker base image for layer caching
export toolName='delphi'
export toolVersion='0.0.2' #the version number cannot contain a "-" - try to use x.x.x notation always
# Don't forget to update version change in README.md!!!!!
# toolName or toolVersion CANNOT contain capital letters or dashes or underscores (Docker registry does not accept this!)

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

###########################################################################################################################################
# IF POSSIBLE, PLEASE DOCUMENT EACH ARGUMENT PROVIDED TO NEURODOCKER. USE THE `# your comment` NOTATION THAT ALLOWS MID-COMMAND COMMENTS
# NOTE 1: THE QUOTES THAT ENCLOSE EACH COMMENT MUST BE BACKQUOTES (`). OTHER QUOTES WON'T WORK!
# NOTE 2: THE BACKSLASH (\) AT THE END OF EACH LINE MUST FOLLOW THE COMMENT. A BACKSLASH BEFORE THE COMMENT WON'T WORK!

# update: 
# 1. update new public key for NVIDIA CUDA Linux (released on 27/04/2022) 
# 2. change CARGO_HOME and RUSTUP_HOME to /usr/local; Cargo's bin directory: /usr/local/cargo/bin
##########################################################################################################################################
neurodocker generate ${neurodocker_buildMode} \
   --base-image docker.io/tensorflow/tensorflow:1.15.0-gpu-py3 `# neurodebian makes it easy to install neuroimaging software, recommended as default` \
   --env DEBIAN_FRONTEND=noninteractive                        `# this disables interactive questions during package installs` \
   --pkg-manager apt                                           `# desired package manager, has to match the base image (e.g. debian needs apt; centos needs yum)` \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll"          `# define the ll command to show detailed list including hidden files`  \
   --run="chmod +x /usr/bin/ll"                                `# make ll command executable`  \
   --run="mkdir ${mountPointList}"                             `# create folders for singularity bind points` \
   --run="pip install -U ray[debug]==0.8.0"                    `# ray 0.8.0 requires the python version 3.6/3.7` \
   --run="pip install ray[tune]==0.8.0 requests scipy"         \
   --run="pip install pandas"                                  \
   --run="pip install argparse"                                \
   --run="pip install nibabel"                                 \
   --run="pip install matplotlib"                              \
   --run="apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/3bf863cc.pub"   `# update new public key for NVIDIA CUDA`\
   --install wget git tar curl ca-certificates libssl-dev clang llvm dpkg                                                     \
   --run="curl -fsSL --retry 5 https://github.com/Kitware/CMake/releases/download/v3.22.2/cmake-3.22.2-linux-x86_64.tar.gz | tar -xz --strip-components=1 -C /usr/local/" `# rust compilling needs higher version of cmake`\
   --run="mkdir -m777 /usr/local/rustup /usr/local/cargo"                                                                     `# make directory for rustuo and cargo`\
   --env RUSTUP_HOME=/usr/local/rustup CARGO_HOME=/usr/local/cargo PATH='$PATH':/usr/local/cargo/bin                          `# set environment path for rustup and cargo before downloading and installing`\
   --run="curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o rustup-init.sh"                                        \
   --run="bash ./rustup-init.sh -y"                            `# install rustup`\
   --run="rustup install nightly"                              `# must use nightly version to compile `\
   --run="rustup default nightly"                              `# make sure to use nightly, in case that stable version is installed as well`\
   --run="git clone https://github.com/yexincheng/delphi.git /opt/encryption"                                                 `# clone delphi homomorphic encryption inference github repo`\
   --workdir /opt/encryption/                                  `# switch to delphi folder`\
   --run="git pull"                                            `# sync changes in delphi repo`\
   --workdir /opt/encryption/rust                              `# rust compiling should be within rust fold`\
   --run="cargo +nightly build --release"                      `# use nightly to build release version`\
   --workdir /opt/encryption/                                  `# back to encryption folder`\
   --env DEPLOY_PATH=/opt/encryption/                          `# specify a path where ALL binary files will be exposed outside the container for the module system. Never expose a directory with system commands (like /bin/ /usr/bin ...)` \
   --copy README.md /README.md                                 `# include readme file in container` \
  > ${imageName}.${neurodocker_buildExt}                       `# LAST COMMENT; NOT FOLLOWED BY BACKSLASH!`
   

if [ "$1" != "" ]; then
   ./../main_build.sh
fi
