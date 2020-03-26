#!/usr/bin/env bash
set -e

imageName='fsl_6p0p3'
buildDate=`date +%Y%m%d`

echo "building $imageName"


#install neurodocker
#pip install --no-cache-dir https://github.com/kaczmarj/neurodocker/tarball/master --user

#upgrade neurodocker
#pip install --no-cache-dir https://github.com/kaczmarj/neurodocker/tarball/master --upgrade

# install development version
pip install --no-cache-dir https://github.com/stebo85/neurodocker/tarball/master --upgrade

mountPointList=$( cat globalMountPointList.txt )

echo "mount points to be created inside image:"
echo $mountPointList

neurodocker generate docker \
   --base debian:stretch \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir ${mountPointList}" \
   --fsl version=6.0.3 \
   --env FSLOUTPUTTYPE=NIFTI_GZ \
   --env DEPLOY_PATH=/opt/fsl-6.0.3/bin/ \
   --user=neuro \
  > Dockerfile.${imageName}


sudo docker build -t ${imageName}:$buildDate -f  Dockerfile.${imageName} .


echo "tesing image in docker now:"
docker run -it ${imageName}:$buildDate

docker tag ${imageName}:$buildDate caid/${imageName}:$buildDate

#run docker login if never logged in on that box:
#docker login

docker push caid/${imageName}:$buildDate
docker tag ${imageName}:$buildDate caid/${imageName}:latest
docker push caid/${imageName}:latest

## BUILD singularity container based on docker container:
echo "BootStrap:docker" > Singularity.${imageName}
echo "From:caid/${imageName}" >> Singularity.${imageName}

if [ -f ${imageName}_${buildDate}.simg ] ; then
       rm ${imageName}_${buildDate}.simg
fi

# local build:
#sudo singularity build ${imageName}_${buildDate}.sif Singularity.${imageName}

# remote build:
# has to be done every 30days:
# singularity remote login
singularity build --remote ${imageName}_${buildDate}.sif Singularity.${imageName}

# test:
#sudo singularity shell --bind $PWD:/data ${imageName}_${buildDate}.simg

git commit -am 'auto commit after build run'
git push
