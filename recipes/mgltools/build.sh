# this template file builds datalad and is then used as a docker base image for layer caching + it contains examples for various things like github install, curl, ...
export toolName='mgltools'
export toolVersion='1.5.7' #the version number cannot contain a "-" - try to use x.x.x notation always
# toolName or toolVersion CANNOT contain capital letters or dashes or underscores (Docker registry does not accept this!)
# https://ccsb.scripps.edu/mgltools/downloads/

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
   --base-image ubuntu:bionic     `# https://github.com/Metaphorme/AutoDock-Vina-Docker` \
   --env DEBIAN_FRONTEND=noninteractive                 `# this disables interactive questions during package installs` \
   --pkg-manager apt                                    `# desired package manager, has to match the base image (e.g. debian needs apt; centos needs yum)` \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll"   `# define the ll command to show detailed list including hidden files`  \
   --run="chmod +x /usr/bin/ll"                         `# make ll command executable`  \
   --run="mkdir -p ${mountPointList}"                      `# create folders for singularity bind points` \
   --install curl ca-certificates tk8.5 libglu1-mesa \
   --run="cd /opt; curl -SL https://ccsb.scripps.edu/mgltools/download/491 | tar -zx; cd mgltools_x86_64Linux2_${toolVersion} \
         && ./install.sh -d /opt/mgltools -c 1" \
   --env PATH='$PATH':/opt/mgltools/bin:/   `# set PATH` \
   --env DEPLOY_PATH=/opt/mgltools/bin/           `# specify a path where ALL binary files will be exposed outside the container for the module system. Never expose a directory with system commands (like /bin/ /usr/bin ...)` \
   --copy README.md /README.md                          `# include readme file in container` \
   --copy test.sh /test.sh                              `# include test file in container` \
  > ${imageName}.${neurodocker_buildExt}                `# LAST COMMENT; NOT FOLLOWED BY BACKSLASH!`
  /opt/mgltools/MGLToolsPckgs/Vision

if [ "$1" != "" ]; then
   ./../main_build.sh
fi


# undo version entry in README.md again after build:
sed -i "s/${toolVersion}/toolVersion/g" README.md