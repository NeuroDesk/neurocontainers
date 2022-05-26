#!/usr/bin/env bash
set -e
# this template file builds datalad and is then used as a docker base image for layer caching + it contains examples for various things like github install, curl, ...
export toolName='civet'
export toolVersion='2.1.1' #the version number cannot contain a "-" - try to use x.x.x notation always
export MNIBASEPATH='/CIVET_Full_Project/Linux-x86_64'
export CIVET='CIVET-2.1.1'
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
   --base-image ubuntu:18.04                `# neurodebian makes it easy to install neuroimaging software, recommended as default` \
   --env DEBIAN_FRONTEND=noninteractive                 `# this disables interactive questions during package installs` \
   --pkg-manager apt                                    `# desired package manager, has to match the base image (e.g. debian needs apt; centos needs yum)` \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll"   `# define the ll command to show detailed list including hidden files`  \
   --run="chmod +x /usr/bin/ll"                         `# make ll command executable`  \
   --run="mkdir ${mountPointList}"                      `# create folders for singularity bind points`  			\
   --install perl imagemagick gnuplot-nox locales gsfonts libtext-format-perl		\
   --install opts="--quiet" build-essential automake libtool bison libz-dev libjpeg-dev libxmu-dev libxi-dev libqt4-dev  \
      libpng-dev libtiff-dev liblcms2-dev flex libx11-dev freeglut3-dev git-lfs ca-certificates		\
   --run="rm /bin/sh && ln -s /bin/bash /bin/sh"        \
   --run="git config --global url.https://github.com/.insteadOf git@github.com:"		\
   --run="git clone git@github.com:aces/CIVET_Full_Project.git" 	\
   --copy . /CIVET_Full_Project/               \
   --workdir /CIVET_Full_Project/           `# create install directory` \
   --run="git lfs pull"		\
   --run="mkdir -p Linux-x86_64/SRC"              \
   --run="tar -zxf TGZ/netpbm-10.35.94.tgz -C /CIVET_Full_Project/Linux-x86_64/SRC"                 \
   --run="cp provision/netpbm/Makefile.config /CIVET_Full_Project/Linux-x86_64/SRC/netpbm-10.35.94"		\
   --run="bash install.sh"		\
   --run="bash job_test"		\
   --workdir /CIVET_Full_Project/Linux-x86_64                  \
   --run="rm -r SRC building man info"                                     \
   --run="chmod --recursive u+rX,g+rX,o+rX /CIVET_Full_Project"      \
   --env PATH=$MNIBASEPATH/$CIVET:$MNIBASEPATH/$CIVET/progs:$MNIBASEPATH/bin:$PATH \
         LD_LIBRARY_PATH=$MNIBASEPATH/lib \
         MNI_DATAPATH=$MNIBASEPATH/share \
         PERL5LIB=$MNIBASEPATH/perl \
         R_LIBS=$MNIBASEPATH/R_LIBS \
         VOLUME_CACHE_THRESHOLD=-1 \
         BRAINVIEW=$MNIBASEPATH/share/brain-view \
         MINC_FORCE_V2=1 \
         MINC_COMPRESS=4 \
         CIVET_JOB_SCHEDULER=DEFAULT                 `# specify indiviual binaries (separated by :) on the PATH that should be exposed outside the container for the module system` \
  > ${imageName}.${neurodocker_buildExt}                `# LAST COMMENT; NOT FOLLOWED BY BACKSLASH!`
if [ "$1" != "" ]; then
   ./../main_build.sh
fi
