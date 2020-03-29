#!/usr/bin/env bash
set -e

echo "buildMode: $buildMode"

if [ "$buildMode" = "docker_singularity" ]; then
       sudo docker build -t ${imageName}:$buildDate -f  recipe.${imageName} .

       if [ "$testImageDocker" = "true" ]; then
              echo "tesing image in docker now:"
              sudo docker run -it ${imageName}:$buildDate
       fi

       sudo docker tag ${imageName}:$buildDate caid/${imageName}:$buildDate

       #run docker login if never logged in on that box:
       #sudo docker login

       sudo docker push caid/${imageName}:$buildDate
       sudo docker tag ${imageName}:$buildDate caid/${imageName}:latest
       sudo docker push caid/${imageName}:latest
fi

if [ "$buildMode" = "docker_singularity" ]; then
       # Build singularity container based on docker container:
       echo "BootStrap:docker" > recipe.${imageName}
       echo "From:caid/${imageName}" >> recipe.${imageName}      
fi

if [ "$localBuild" = "true" ]; then
       if [ -f ${imageName}_${buildDate}.sif ] ; then
                     rm ${imageName}_${buildDate}.sif
       fi

       sudo singularity build ${imageName}_${buildDate}.sif recipe.${imageName}
fi

if [ "$remoteBuild" = "true" ]; then
       # remote login has to be done every 30days:
       # singularity remote login
       singularity build --remote ${imageName}_${buildDate}.sif recipe.${imageName}
fi

if [ "$testImageSingularity" = "true" ] && [ "$localBuild" = "true" ]; then
       sudo singularity shell --bind $PWD:/data ${imageName}_${buildDate}.simg
fi


if [ "$uploadToSwift" = "true" ] && [ "$localBuild" = "true" ]; then
       source ../setupSwift.sh
       swift upload singularityImages ${imageName}_${buildDate}.sif --segment-size 1073741824  
fi

git commit -am 'auto commit after build run'
git push
