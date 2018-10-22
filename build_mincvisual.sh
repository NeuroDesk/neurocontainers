#!/usr/bin/env bash

imageName='minc_1p9p16_visual'
buildDate=`date +%Y%m%d`

sudo singularity build ${imageName}_${buildDate}.simg Singularity.${imageName}

source ../setupSwift.sh
swift upload singularityImages ${imageName}_${buildDate}.simg

git commit -am 'auto commit after build run'
git push
