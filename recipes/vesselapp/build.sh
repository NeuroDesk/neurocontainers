#!/usr/bin/env bash
set -e

export toolName='vesselapp'
export toolVersion='1.0.0'
# Don't forget to update version change in README.md!!!!!

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug="true"
fi

source ../main_setup.sh

echo "FROM davidsliu/vessel-app:20211109" > ${imageName}.Dockerfile

# neurodocker generate ${neurodocker_buildMode} \
#    --base-image davidsliu/vessel-app:20211109 \
#    --pkg-manager apt \
#   > ${imageName}.Dockerfile

if [ "$debug" = "true" ]; then
   ./../main_build.sh
fi
