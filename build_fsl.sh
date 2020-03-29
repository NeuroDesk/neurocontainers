#!/usr/bin/env bash
set -e

imageName='fsl_6p0p3'
buildDate=`date +%Y%m%d`
buildMode='docker_singularity'  #singularity or docker_singularity
localBuild='true'
uploadTo='swift'
testImageSingularity='false'
testImageDocker='false'

if [ "$buildMode" = "singularity" ]; then
       neurodocker_buildMode="singularity"
else
       neurodocker_buildMode="docker"
fi

echo "building $imageName in mode $buildMode" 


#install neurodocker
#pip install --no-cache-dir https://github.com/kaczmarj/neurodocker/tarball/master --user

#upgrade neurodocker
#pip install --no-cache-dir https://github.com/kaczmarj/neurodocker/tarball/master --upgrade

# install development version
pip install --no-cache-dir https://github.com/stebo85/neurodocker/tarball/master --upgrade

mountPointList=$( cat globalMountPointList.txt )

echo "mount points to be created inside image:"
echo $mountPointList

neurodocker generate ${neurodocker_buildMode} \
   --base debian:stretch \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir ${mountPointList}" \
   --fsl version=6.0.3 \
   --env FSLOUTPUTTYPE=NIFTI_GZ \
   --env DEPLOY_PATH=/opt/fsl-6.0.3/bin/:/opt/fsl-6.0.3/fslpython/envs/fslpython/bin/ \
   --user=neuro \
  > recipe.${imageName}

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
else
       # remote login has to be done every 30days:
       singularity remote login
       singularity build --remote ${imageName}_${buildDate}.sif recipe.${imageName}
fi

if [ "$testImageSingularity" = "true" ]; then
       sudo singularity shell --bind $PWD:/data ${imageName}_${buildDate}.simg
fi


if [ "$uploadTo" = "swift" ]; then
       source ../setupSwift.sh
       swift upload singularityImages ${imageName}_${buildDate}.sif --segment-size 1073741824  
fi

git commit -am 'auto commit after build run'
git push
