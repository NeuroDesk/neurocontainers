#!/usr/bin/env bash
set -e

export toolName='laynii'
export toolVersion='2.2.1' # https://github.com/layerfMRI/LAYNII/releases
# Don't forget to update version change in README.md!!!!!

# !!!!
# You can test the container build locally by running `bash build.sh -ds`
# !!!!


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
   --base-image ubuntu:18.04                            `# any linux version will do` \
   --pkg-manager apt                                    `# not sure if I actually need this` \
   --env DEBIAN_FRONTEND=noninteractive                 `# this disables interactive questions during package installs` \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll"   `# define the ll command to show detailed list including hidden files`  \
   --run="chmod +x /usr/bin/ll"                         `# make ll command executable`  \
   --run="mkdir -p ${mountPointList}"                      `# create folders for singularity bind points` \
   --install wget ca-certificates unzip \
   --workdir /opt/${toolName}-${toolVersion}/ \
   --run="wget https://github.com/layerfMRI/LAYNII/releases/download/v2.2.1/LayNii_v${toolVersion}_Linux64.zip \
            && unzip LayNii_v${toolVersion}_Linux64.zip \
            && rm LayNii_v${toolVersion}_Linux64.zip" \
   --env DEPLOY_PATH=/opt/${toolName}-${toolVersion}/ \
   --env PATH='$PATH':/opt/${toolName}-${toolVersion}/ \
   --copy README.md /README.md                          `# include readme file in container` \
  > ${imageName}.${neurodocker_buildExt}                `# LAST COMMENT; NOT FOLLOWED BY BACKSLASH!`

if [ "$1" != "" ]; then
   ./../main_build.sh
fi
