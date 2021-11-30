#!/usr/bin/env bash
set -e

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug="true"
fi

export toolName='freesurfer'
export toolVersion=7.2.0
# Don't forget to update version change in README.md!!!!!

source ../main_setup.sh


neurodocker generate ${neurodocker_buildMode} \
   --base-image centos:8 \
   --pkg-manager yum \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir ${mountPointList}" \
   --run="yum upgrade -y dnf" \
   --run="yum upgrade -y rpm" \
   --install wget \
   --run="wget https://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/7.2.0/freesurfer-CentOS8-7.2.0-1.x86_64.rpm" \
   --run="yum --nogpgcheck -y localinstall freesurfer-CentOS8-7.2.0-1.x86_64.rpm" \
   --run="ln -s /usr/local/freesurfer/7.2.0-1/ /opt/${toolName}-${toolVersion}" \
   --run="ln -s /usr/local/freesurfer/7.2.0-1/FreeSurferEnv.sh /usr/local/freesurfer/" \
   --env FREESURFER_HOME=/usr/local/freesurfer \
   --env TERM=xterm \
   --env SHLVL=1 \
   --env FS_OVERRIDE=0 \
   --env PATH=/opt/${toolName}-${toolVersion}/bin:/opt/${toolName}-${toolVersion}/fsfast/bin:/opt/${toolName}-${toolVersion}/bin:/opt/${toolName}-${toolVersion}/fsfast/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
   --env FREESURFER=/opt/${toolName}-${toolVersion} \
   --env DEPLOY_PATH=/opt/${toolName}-${toolVersion}/bin/ \
   --copy README.md /README.md \
  > ${imageName}.${neurodocker_buildExt}

if [ "$debug" = "true" ]; then
   ./../main_build.sh
fi

# I applied for the freesurfer license for 400 users. But license is not included!
   # --copy license.txt /opt/${toolName}-${toolVersion}/license.txt \
# 