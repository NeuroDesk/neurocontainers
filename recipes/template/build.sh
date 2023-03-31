# this template file builds datalad and is then used as a docker base image for layer caching + it contains examples for various things like github install, curl, ...
export toolName='datalad'
# toolName or toolVersion CANNOT contain capital letters or dashes or underscores (Docker registry does not accept this!)

export toolVersion='1.0.20211006' 
# the version number cannot contain a "-" - try to use x.x.x notation always
# toolVersion will automatically be written into README.md - for this to work leave "toolVersion" in the README unaltered.

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
# NOTE 3: COMMENT LINES, I.E. LINES THAT START WITH #, CANNOT BE INCLUDED IN THE MIDDLE OF THE neurodocker generate COMMAND. INSTEAD,
#         USE AN EMPTY LINE AND PUT YOUR COMMENT AT THE END USING THIS FORMAT: `# your comment goes here` \ 
##########################################################################################################################################
neurodocker generate ${neurodocker_buildMode} \
   --base-image neurodebian:sid-non-free                `# neurodebian makes it easy to install neuroimaging software, recommended as default` \
   --env DEBIAN_FRONTEND=noninteractive                 `# this disables interactive questions during package installs` \
   --pkg-manager apt                                    `# desired package manager, has to match the base image (e.g. debian needs apt; centos needs yum)` \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll"   `# define the ll command to show detailed list including hidden files`  \
   --run="chmod +x /usr/bin/ll"                         `# make ll command executable`  \
   --run="mkdir -p ${mountPointList}"                      `# create folders for singularity bind points` \
   --install wget git curl ca-certificates datalad datalad-container unzip`# install apt-get packages` \
   --workdir /opt/${toolName}-${toolVersion}/           `# create install directory` \
   --run="curl -fsSL --retry 5 https://github.com/JacobBumgarner/VesselVio/archive/refs/tags/v1.1.1.tar.gz | tar -xz -C /opt/${toolName}-${toolVersion} --strip-components 1" `# download a github release file and unpack` \
   --run="wget --quiet -O surfice_linux.zip 'https://github.com/neurolabusc/surf-ice/releases/download/v${toolVersion}/surfice_linux.zip' \
      && unzip surfice_linux.zip  \
      && rm -rf surfice_linux.zip" \
   --env PATH='$PATH':/opt/${toolName}-${toolVersion}   `# set PATH` \
   --env DEPLOY_PATH=/opt/${toolName}-latest/           `# specify a path where ALL binary files will be exposed outside the container for the module system. Never expose a directory with system commands (like /bin/ /usr/bin ...)` \
   --env DEPLOY_BINS=datalad:bidscoiner                 `# specify indiviual binaries (separated by :) on the PATH that should be exposed outside the container for the module system` \
   --copy README.md /README.md                          `# include readme file in container` \
   --copy *.sh /neurodesk/                              `# copy test scripts to /neurodesk folder - build.sh will be included as well, which is a good idea` \
   --run="chmod +x /neurodesk/*.sh"                     `# allow execution of all shell scripts in /neurodesk inside the cotainer` \
  > ${imageName}.${neurodocker_buildExt}                `# LAST COMMENT; NOT FOLLOWED BY BACKSLASH!`
  
if [ "$1" != "" ]; then
   ./../main_build.sh
fi
