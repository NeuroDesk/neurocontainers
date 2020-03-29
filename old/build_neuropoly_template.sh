#!/usr/bin/env bash
set -e

imageName='neuropoly_template'
buildDate=`date +%Y%m%d`

echo "building $imageName"


#install neurodocker
#pip3 install --no-cache-dir https://github.com/kaczmarj/neurodocker/tarball/master --user

#upgrade neurodocker
#pip install --no-cache-dir https://github.com/kaczmarj/neurodocker/tarball/master --upgrade
#or
#pip install --no-cache-dir https://github.com/stebo85/neurodocker/tarball/master --upgrade


neurodocker generate docker \
   --base=ubuntu:xenial \
   --pkg-manager apt \
   --install git \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --copy globalMountPointList.txt /globalMountPointList.txt \
   --run="mkdir \`cat /globalMountPointList.txt\`" \
   --run="git clone --depth=1 --branch=master https://github.com/neuropoly/spinalcordtoolbox.git sct" \
   --workdir /sct \
   --run="yes yes | ./install_sct" \
   --run="git clone https://github.com/vfonov/nist_mni_pipelines.git /nist_mni_pipelines" \
   --env PYTHONPATH="/nist_mni_pipelines/:/nist_mni_pipelines:/nist_mni_pipelines/ipl/:/nist_mni_pipelines/ipl" \
   --pkg-manager apt \
   --install python-dev \
   --pkg-manager apt \
   --install python-pip \
   --run="pip install --upgrade setuptools --user python" \
   --run="pip install scoop" \
   --minc version=1.9.15 method=binaries \
   --run="pip install numpy" \
   --run="pip install scipy" \
   --run="pip install six" \
   --run="pip install cffi" \
   --workdir / \
   --run="git clone https://github.com/vfonov/minc2-simple" \
   --install gcc \
   --env MINC_TOOLKIT=/opt/minc-1.9.15/ \
   --run="/usr/bin/python /minc2-simple/python/setup.py build" \
   --run="/usr/bin/python /minc2-simple/python/setup.py install" \
   --user=neuro \
   --env DEPLOY_PATH=/ \
   > Dockerfile.${imageName}

#

   #--run="/usr/bin/python /python/setup.py build" \
#git clone --depth=1 --branch=master https://github.com/neuropoly/spinalcordtoolbox.git sct
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
