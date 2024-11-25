# this template file builds datalad and is then used as a docker base image for layer caching + it contains examples for various things like github install, curl, ...
export toolName='ilastik'
# toolName or toolVersion CANNOT contain capital letters or dashes or underscores (Docker registry does not accept this!)

export toolVersion='1.4.0' 
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

neurodocker generate ${neurodocker_buildMode} \
--base-image ubuntu:22.04 \
--pkg-manager apt \
--env DEBIAN_FRONTEND=noninteractive \
--run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
--run="chmod +x /usr/bin/ll" \
--run="mkdir -p ${mountPointList}" \
--install ca-certificates lbzip2 libgl1 wget libqt5gui5 \
--workdir /opt \
--run='wget https://files.ilastik.org/ilastik-1.4.0-Linux.tar.bz2 \
      && tar -xf ilastik-1.4.0-Linux.tar.bz2 \
      && rm -rf ilastik-1.4.0-Linux.tar.bz2' \
--env PATH='$PATH':/opt/${toolName}-${toolVersion}-Linux/ `# MANDATORY: add your tool executables to PATH` \
--env DEPLOY_PATH=/opt/${toolName}-${toolVersion}-Linux/ `# MANDATORY: define which directory's binaries should be exposed to module system (alternative: DEPLOY_BINS -> only exposes binaries in the list)` \
--copy README.md /README.md \
  > ${imageName}.${neurodocker_buildExt}                `# THIS IS THE LAST COMMENT; NOT FOLLOWED BY BACKSLASH!`
  
if [ "$1" != "" ]; then
   ./../main_build.sh
fi
