# this template file builds datalad and is then used as a docker base image for layer caching + it contains examples for various things like github install, curl, ...
export toolName='vina'
export toolVersion='1.2.3' #the version number cannot contain a "-" - try to use x.x.x notation always
# toolName or toolVersion CANNOT contain capital letters or dashes or underscores (Docker registry does not accept this!)
# https://github.com/ccsb-scripps/AutoDock-Vina/releases

# !!!!
# You can test the container build locally by running `bash build.sh -ds`
# !!!!

# Add version to README.md
sed -i "s/toolVersion/${toolVersion}/g" README.md

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi
source ../main_setup.sh
###########################################################################################################################################
# IF POSSIBLE, PLEASE DOCUMENT EACH ARGUMENT PROVIDED TO NEURODOCKER. USE THE `# your comment` NOTATION THAT ALLOWS MID-COMMAND COMMENTS
# NOTE 1: THE QUOTES THAT ENCLOSE EACH COMMENT MUST BE BACKQUOTES (`). OTHER QUOTES WON'T WORK!
# NOTE 2: THE BACKSLASH (\) AT THE END OF EACH LINE MUST FOLLOW THE COMMENT. A BACKSLASH BEFORE THE COMMENT WON'T WORK!
# NOTE 3: COMMENT LINES, I.E. LINES THAT START WITH #, CANNOT BE INCLUDED IN THE MIDDLE OF THE neurodocker generate COMMAND. INSTEAD,
#         USE AN EMPTY LINE AND PUT YOUR COMMENT AT THE END USING THIS FORMAT: `# your comment goes here` \ 
##########################################################################################################################################
neurodocker generate ${neurodocker_buildMode} \
   --base-image ghcr.io/metaphorme/vina-all:release     `# https://github.com/Metaphorme/AutoDock-Vina-Docker` \
   --env DEBIAN_FRONTEND=noninteractive                 `# this disables interactive questions during package installs` \
   --pkg-manager apt                                    `# desired package manager, has to match the base image (e.g. debian needs apt; centos needs yum)` \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll"   `# define the ll command to show detailed list including hidden files`  \
   --run="chmod +x /usr/bin/ll"                         `# make ll command executable`  \
   --run="mkdir -p ${mountPointList}"                      `# create folders for singularity bind points` \
   --install libxml2                                    `# install apt-get packages` \
   --env DEPLOY_PATH=/opt/AutoDock-Vina/build/linux/release/,/opt/adfr/bin           `# specify a path where ALL binary files will be exposed outside the container for the module system. Never expose a directory with system commands (like /bin/ /usr/bin ...)` \
   --copy README.md /README.md                          `# include readme file in container` \
   --copy test.sh /test.sh                              `# include test file in container` \
  > ${imageName}.${neurodocker_buildExt}                `# LAST COMMENT; NOT FOLLOWED BY BACKSLASH!`
  
if [ "$1" != "" ]; then
   ./../main_build.sh
fi


# undo version entry in README.md again after build:
sed -i "s/${toolVersion}/toolVersion/g" README.md