export toolName='globus'
export toolVersion='3.2.0' 

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi
source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base-image ubuntu:22.04                            `# ubuntu ` \
   --pkg-manager apt                                    `# RECOMMENDED TO KEEP AS IS: desired package manager, has to match the base image (e.g. debian needs apt; centos needs yum)` \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll"   `# RECOMMENDED TO KEEP AS IS: define the ll command to show detailed list including hidden files`  \
   --run="chmod +x /usr/bin/ll"                         `# RECOMMENDED TO KEEP AS IS: make ll command executable`  \
   --run="mkdir -p ${mountPointList}"                   `# MANDATORY: create folders for singularity bind points` \
   --install wget ca-certificates tk tcllib midori           `# RECOMMENDED: install system packages` \
   --workdir /opt                                       `# install in opt` \
   --run="wget https://downloads.globus.org/globus-connect-personal/linux/stable/globusconnectpersonal-latest.tgz \
    && tar xzf globusconnectpersonal-latest.tgz \
    && rm -rf globusconnectpersonal-latest.tgz"        `# download and unpack in opt` \
   --env DEPLOY_PATH=/opt/${toolName}-${toolVersion}/ `# expose binaries` \
   --env PATH='$PATH':/opt/${toolName}-${toolVersion}/ \
   --copy README.md /README.md                          `# MANDATORY: include readme file in container` \
  > ${imageName}.${neurodocker_buildExt}                `# THIS IS THE LAST COMMENT; NOT FOLLOWED BY BACKSLASH!`
  
if [ "$1" != "" ]; then
   ./../main_build.sh
fi
