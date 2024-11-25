#!/usr/bin/env bash
set -e

export toolName='vesselvio'
export toolVersion='1.1.2' #the version number cannot contain a "-" - try to use x.x.x notation always
# https://github.com/JacobBumgarner/VesselVio/releases

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

###########################################################################################################################################
# IF POSSIBLE, PLEASE DOCUMENT EACH ARGUMENT PROVIDED TO NEURODOCKER. USE THE `# your comment` NOTATION THAT ALLOWS MID-COMMAND COMMENTS
# NOTE 1: THE QUOTES THAT ENCLOSE EACH COMMENT MUST BE BACKQUOTES (`). OTHER QUOTES WON'T WORK!
# NOTE 2: THE BACKSLASH (\) AT THE END OF EACH LINE MUST FOLLOW THE COMMENT. A BACKSLASH BEFORE THE COMMENT WON'T WORK!
##########################################################################################################################################
neurodocker generate ${neurodocker_buildMode} \
   --base-image ubuntu:22.04              `# neurodebian makes it easy to install neuroimaging software, recommended as default` \
   --env DEBIAN_FRONTEND=noninteractive                 `# this disables interactive questions during package installs` \
   --pkg-manager apt                                    `# desired package manager, has to match the base image (e.g. debian needs apt; centos needs yum)` \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll"   `# define the ll command to show detailed list including hidden files`  \
   --run="chmod +x /usr/bin/ll"                         `# make ll command executable`  \
   --run="mkdir -p ${mountPointList}"                      `# create folders for singularity bind points` \
   --install git ca-certificates curl libqt5gui5 `# install packages mesa is for swrast to work; the rest for QT5 xcb` \
   --miniconda version=latest \
      conda_install='python=3.8.8' \
   --run="git clone https://github.com/JacobBumgarner/VesselVio.git /opt/${toolName}-${toolVersion}/" \
   --run="pip install -r /opt/${toolName}-${toolVersion}/requirements.txt" \
   --env DEPLOY_PATH=/opt/${toolName}-${toolVersion}/    `# specify a path where ALL binary files will be exposed outside the container for the module system. Never expose a directory with system commands (like /bin/ /usr/bin ...)` \
   --copy README.md /README.md                           `# include readme file in container` \
   --env PATH='$PATH':/opt/${toolName}-${toolVersion}   `# set PATH` \
   --copy vesselvio /opt/${toolName}-${toolVersion}/     `# include startup file in container` \
   --run="chmod a+x /opt/${toolName}-${toolVersion}/vesselvio" \
  > ${imageName}.${neurodocker_buildExt}

   # --run="curl -fsSL --retry 5 https://github.com/JacobBumgarner/VesselVio/archive/refs/tags/v${toolVersion}.tar.gz | tar -xz -C /opt/${toolName}-${toolVersion} --strip-components 1" \
   # --workdir /opt/${toolName}-${toolVersion}/           `# create install directory` \

if [ "$1" != "" ]; then
   ./../main_build.sh
fi
