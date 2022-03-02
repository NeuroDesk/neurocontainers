#!/usr/bin/env bash
set -e

# this template file builds itksnap and is then used as a docker base image for layer caching
export toolName='datalad'
export toolVersion='0.15.3' 
# Don't forget to update version change in README.md!!!!!
# toolName or toolVersion CANNOT contain capital letters (Docker registry does not accept this!)

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
   --base-image neurodebian:sid-non-free                `# neurodebian makes it easy to install neuroimaging software, recommended as deafult` \
   --env DEBIAN_FRONTEND=noninteractive                 `# ask author for more details on why this is necessary` \
   --pkg-manager apt                                    `# desired package manager` \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll"   `# define the ll command to show detailed list including hidden files`  \
   --run="chmod +x /usr/bin/ll"                         `# make ll command executable`  \
   --run="mkdir ${mountPointList}"                      `# create folders for binds` \
   --install datalad datalad-container                  `# install datalad and datalad-container using the Neurodocker arguments` \
   --env DEPLOY_BINS=datalad                            `# specify what are the binary files that should have transparent singularity generated for them` \
   --copy README.md /README.md                          `# include readmefile in container` \
  > ${imageName}.${neurodocker_buildExt}                `# LAST COMMENT; NOT FOLLOWED BY BACKSLASH!`

if [ "$1" != "" ]; then
   ./../main_build.sh
fi
