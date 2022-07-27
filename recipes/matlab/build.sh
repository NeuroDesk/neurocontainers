#!/usr/bin/env bash
set -e

# this template file builds datalad and is then used as a docker base image for layer caching + it contains examples for various things like github install, curl, ...
export toolName='matlab'
export toolVersion='2022a' #the version number cannot contain a "-" - try to use x.x.x notation always
# Don't forget to update version change in README.md!!!!!
# toolName or toolVersion CANNOT contain capital letters or dashes or underscores (Docker registry does not accept this!)

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
   --base-image mathworks/matlab:r2022a                 `# use Matlab 2022a docker container provided by Mathworks` \
   --user root                                          `# change user to root, as the Matlab container runs with Matlab user` \
   --env DEBIAN_FRONTEND=noninteractive                 `# The matlab image uses Ubuntu, so it's Debian` \
   --pkg-manager apt                                    `# desired package manager, has to match the base image (e.g. debian needs apt; centos needs yum)` \
   `#--run="sudo chmod u+x /usr/bin /"                         # make folders writeable`  \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll"   `# define the ll command to show detailed list including hidden files`  \
   --run="chmod +x /usr/bin/ll"                         `# make ll command executable`  \
   --run="mkdir ${mountPointList}"                      `# create folders for singularity bind points` \
   --install wget git curl ca-certificates datalad datalad-container unzip`# install apt-get packages` \
         						`# REMOVED as not necessary:    "--workdir /opt/${toolName}-${toolVersion}/"  create install directory` \
							`# REMOVED as not necessary:   --run="curl -fsSL --retry 5 https://github.com/JacobBumgarner/VesselVio/archive/refs/tags/v1.1.1.tar.gz | tar -xz -C /opt/${toolName}-${toolVersion} --strip-components 1" # download a github release file and unpack` \
   --miniconda version=latest \
      conda_install='python=3.8.8' \
   --env PATH='${PATH}:/opt/matlab/R${toolVersion}b/bin/'   	 `# set PATH; not required to run matlab, but required for other Matlab tools like mex` \
   `# REMOVED so to not conflict with matlab in /usr/local/bin: --env DEPLOY_PATH='/opt/matlab/R${toolVersion}b/bin/'  # specify a path where ALL binary files will be exposed outside the container for the module system. Never expose a directory with system commands (like /bin/ /usr/bin ...)` \
   --env DEPLOY_BINS=datalad:matlab:mex                 `# specify indiviual binaries (separated by :) on the PATH that should be exposed outside the container for the module system` \
   --env MLM_LICENSE_FILE='~/Downloads'		 `# tell Matlab to look for the license file in Downloads under the home directory. There is the default download folder in Neurodesktop` \
   --copy README.md /README.md                          `# include readme file in container` \
   --copy test.sh /test.sh                              `# include test file in container` \
   --run="rm /usr/local/bin/matlab"			`# rm original matlab symbolic link` \
   --copy matlab /usr/local/bin/matlab `# replace original matlab with a script that sets MLM_LICENSE_FILE and then call matlab; license dir is set to ~/Downloads because there is where Firefox download the license to` \
   --run="chmod a+x /usr/local/bin/matlab"     		`# make matlab executables` \
  > ${imageName}.${neurodocker_buildExt}                `# LAST COMMENT; NOT FOLLOWED BY BACKSLASH!`

if [ "$1" != "" ]; then
   ./../main_build.sh
fi
