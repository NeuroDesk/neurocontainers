#!/usr/bin/env bash
set -e

# this template file builds sigviewer and is then used as a docker base image for layer caching
export toolName='sigviewer'
export toolVersion='0.6.4' 
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
##########################################################################################################################################
neurodocker generate docker \
   --base-image neurodebian:bullseye                	`# neurodebian makes it easy to install neuroimaging software, recommended as default` \
   --env DEBIAN_FRONTEND=noninteractive                 `# this disables interactive questions during package installs` \
   --pkg-manager apt                                    `# choose package manager` \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll"   `# define the ll command to show detailed list including hidden files` \
   --run="chmod +x /usr/bin/ll"                         `# make ll command executable` \
   --run="mkdir ${mountPointList}"                      `# create folders for singularity bind points` \
   --install sigviewer                                  `# install the software package` \
   --env DEPLOY_BINS=${toolName}                        `# specify indiviual binaries (separated by :) on the PATH that should be exposed outside the container for the module system` \
   --copy README.md /README.md                          `# include readme file in container` \
> ${imageName}.${neurodocker_buildExt}                `# LAST COMMENT; NOT FOLLOWED BY BACKSLASH!`

if [ "$1" != "" ]; then
   ./../main_build.sh
fi
