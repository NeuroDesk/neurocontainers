#!/usr/bin/env bash

imageName='minc_1p9p16'
buildDate=`date +%Y%m%d`

sudo singularity build ${imageName}_${buildDate}.simg Singularity.${imageName}

