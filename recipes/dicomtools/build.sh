#!/usr/bin/env bash
set -e

# this template file builds tools required for handling dicoms
export toolName='dicomtools'
export toolVersion='1.0.0'
# Don't forget to update version change in README.md!!!!!

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

# yes | pip uninstall neurodocker
source ../main_setup.sh --reinstall_neurodocker=false

neurodocker generate ${neurodocker_buildMode} \
   --base-image ubuntu:24.10 \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir -p ${mountPointList}" \
   --install opts="--quiet" wget zip libgl1 libgtk2.0-0 dcmtk xmedcon pigz libxcb-cursor0 \
   --dcm2niix method=source version=latest \
   --env DEPLOY_BINS=dcm2niix:dcm2pnm:dcmcjpeg:dcmconv:dcmdjpeg:dcmdrle:dcmdump:dcmgpdir:dcmj2pnm:dcmmkcrv:dcmmklut:dcmp2pgm:dcmprscu:dcmpsmk:dcmpsrcv:dcmqridx:dcmqrti:dcmrecv:dcmsend:xmedcon \
   --copy README.md /README.md \
  > ${toolName}_${toolVersion}.Dockerfile


if [ "$1" != "" ]; then
   ./../main_build.sh
fi
