export toolName='elastics'
export toolVersion='5.1.0'
# https://github.com/SuperElastix/elastix/releases 

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi
source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base-image ubuntu:20.04                `# this is the version elastix was build against` \
   --env DEBIAN_FRONTEND=noninteractive                 `# RECOMMENDED TO KEEP AS IS: this disables interactive questions during package installs` \
   --pkg-manager apt                                    `# RECOMMENDED TO KEEP AS IS: desired package manager, has to match the base image (e.g. debian needs apt; centos needs yum)` \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll"   `# RECOMMENDED TO KEEP AS IS: define the ll command to show detailed list including hidden files`  \
   --run="chmod +x /usr/bin/ll"                         `# RECOMMENDED TO KEEP AS IS: make ll command executable`  \
   --run="mkdir -p ${mountPointList}"                   `# MANDATORY: create folders for singularity bind points` \
   --install wget ca-certificates unzip libgomp1 \
   --workdir /opt/${toolName}-${toolVersion}/ \
   --run="wget https://github.com/SuperElastix/elastix/releases/download/${toolVersion}/elastix-${toolVersion}-linux.zip \
            && unzip elastix-${toolVersion}-linux.zip \
            && rm elastix-${toolVersion}-linux.zip" \
   --env PATH='$PATH':/opt/${toolName}-${toolVersion}/bin \
   --env LD_LIBRARY_PATH='$LD_LIBRARY_PATH':/opt/${toolName}-${toolVersion}/lib \
   --run="chmod a+x /opt/${toolName}-${toolVersion}/bin/*" \
   --env DEPLOY_PATH=/opt/${toolName}-${toolVersion}/bin/ \
   --copy README.md /README.md                          `# MANDATORY: include readme file in container` \
   --copy * /neurodesk/                              `# MANDATORY: copy test scripts to /neurodesk folder - build.sh will be included as well, which is a good idea` \
  > ${imageName}.${neurodocker_buildExt}                `# THIS IS THE LAST COMMENT; NOT FOLLOWED BY BACKSLASH!`
  
if [ "$1" != "" ]; then
   ./../main_build.sh
fi
