#!/usr/bin/env bash
set -e

export toolName='wftfi'
export toolVersion='1.0.0'
export GPU_FLAG=true
# Don't forget to update version change in README.md!!!!!

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base-image ubuntu:16.04 \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir ${mountPointList}" \
   --install git \
   --workdir /opt \
   --install="curl ca-certificates" \
   --run="git clone https://gitlab.com/thomshaw92/wftfi.git" \
   --copy environment.yml /opt/wftfi/ \
   --workdir /opt/wftfi \
   --miniconda version=4.7.12.1 \
         env_name="wfTFI" \
         yaml_file="/opt/wftfi/environment.yml" \
   --env DEPLOY_BINS=wfTFI \
   --copy README.md /README.md \
  > ${toolName}_${toolVersion}.Dockerfile

if [ "$1" != "" ]; then
   ./../main_build.sh
fi

# curl -o example_data.nii.gz -L https://files.au-1.osf.io/v1/resources/bt4ez/providers/osfstorage/5e9bf3e2d697350662be21ab?action=download&direct&version=1
#--run="echo 'import os' > /opt/HD-BET/HD_BET/paths.py" \