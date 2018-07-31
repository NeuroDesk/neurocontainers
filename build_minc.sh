#!/usr/bin/env bash
set -e

imageName='minc_1p9p16'
buildDate=`date +%Y%m%d`

echo "building $imageName"


#install neurodocker
#pip3 install --no-cache-dir https://github.com/kaczmarj/neurodocker/tarball/master --user

#upgrade neurodocker
#pip install --no-cache-dir https://github.com/kaczmarj/neurodocker/tarball/master --upgrade
#or
pip install --no-cache-dir https://github.com/stebo85/neurodocker/tarball/master --upgrade


neurodocker generate docker \
   --base=centos:6.10 \
   --pkg-manager yum \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --copy globalMountPointList.txt /globalMountPointList.txt \
   --run="mkdir \`cat /globalMountPointList.txt\`" \
   --minc version=1.9.16 method=binaries \
   --user=neuro \
   --env DEPLOY_PATH=/opt/minc-1.9.16/bin/ \
   > Dockerfile.${imageName}


docker build -t ${imageName}:$buildDate -f  Dockerfile.${imageName} .

#test:
docker run -it ${imageName}:$buildDate
#exit 0



docker tag ${imageName}:$buildDate caid/${imageName}:$buildDate
#docker login
docker push caid/${imageName}:$buildDate
docker tag ${imageName}:$buildDate caid/${imageName}:latest
docker push caid/${imageName}:latest

echo "BootStrap:docker" > Singularity.${imageName}
echo "From:caid/${imageName}" >> Singularity.${imageName}

sudo singularity build ${imageName}_${buildDate}.simg Singularity.${imageName}

source ../setupSwift.sh
swift upload singularityImages ${imageName}_${buildDate}.simg

git commit -am 'auto commit after build run'
git push
