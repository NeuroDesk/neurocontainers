#!/usr/bin/env bash
set -e

# this template file builds jamovi and is then used as a docker base image for layer caching
export toolName='jamovi'
export toolVersion='2.3' 
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
neurodocker generate ${neurodocker_buildMode} \
   --base-image jamovi/jamovi:2.3.17                        `# CentOS from version 7 onwards has flatpak pre-installed` \
   --pkg-manager yum                                    `# this chooses the package manager to use ` \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll"   `# define the ll command to show detailed list including hidden files`  \
   --run="chmod +x /usr/bin/ll"                         `# make ll command executable`  \
   --run="mkdir -p ${mountPointList}"                      `# create folders for singularity bind points` \
   --install flatpak ca-certificates \
   --run="flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo" \
   --run="flatpak install flathub org.jamovi.jamovi -y" `# install jamovi using the flatpak manager` \
   --env DEPLOY_PATH=/usr/bin/           `# specify a path where ALL binary files will be exposed outside the container for the module system` \
   --env DEPLOY_BINS=flatpak                            `# specify individual binaries (separated by :) on the PATH that should be exposed outside the container for the module system` \
   --copy README.md /README.md                          `# include readme file in container` \
  > ${imageName}.${neurodocker_buildExt}                `# LAST COMMENT; NOT FOLLOWED BY BACKSLASH!`

if [ "$1" != "" ]; then
   ./../main_build.sh
fi

# WARNING: THE flatpak install does not work, because it requires usernamespaces. It would be best, to start from the official jamovi container: https://github.com/jamovi/jamovi/blob/current-dev/docker-compose.yaml