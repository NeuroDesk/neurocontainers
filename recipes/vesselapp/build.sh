#!/usr/bin/env bash
set -e

export toolName='vesselapp'
export toolVersion='0.3.1'
# Don't forget to update version change in README.md!!!!!

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

echo "FROM davidsliu/vessel-app:20211214" > ${imageName}.${neurodocker_buildExt}
echo "COPY README.md /README.md" >> ${imageName}.${neurodocker_buildExt}

if [ "$1" != "" ]; then
   ./../main_build.sh
fi
