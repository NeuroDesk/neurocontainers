#!/usr/bin/env bash
set -e

export toolName='vesselapp'
export toolVersion='0.3.1'
# Don't forget to update version change in README.md!!!!!

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug="true"
fi

source ../main_setup.sh

echo "FROM davidsliu/vessel-app:20211214" > ${imageName}.Dockerfile

if [ "$debug" = "true" ]; then
   ./../main_build.sh
fi
