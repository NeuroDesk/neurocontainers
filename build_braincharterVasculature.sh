#!/usr/bin/env bash
set -e

imageName='braincharter_vasculature_master'
buildDate=`date +%Y%m%d`

echo "building $imageName"


#install neurodocker
#pip3 install --no-cache-dir https://github.com/kaczmarj/neurodocker/tarball/master --user

#upgrade neurodocker
#pip3 install --no-cache-dir https://github.com/kaczmarj/neurodocker/tarball/master --upgrade


neurodocker generate docker \
   --base=ubuntu:xenial \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --copy globalMountPointList.txt /globalMountPointList.txt \
   --run="mkdir \`cat /globalMountPointList.txt\`" \
   --ants version=2.3.1 \
   --afni version=latest \
   --install python2.7 git python-pip libinsighttoolkit4-dev cmake-curses-gui gcc vmtk python-setuptools python-numpy python-dev python-dipy make g++ insighttoolkit4-python python-vtkgdcm python-gdcm libvtkgdcm2.6 libvtkgdcm2-dev libvtkgdcm-tools libvtkgdcm-java libvtkgdcm-cil libgdcm2.6-dbg libgdcm2.6 libgdcm2-dev libgdcm-tools libgdcm-java libgdcm-cil gdcm-doc libboost-all-dev fftw3 libfftw3-dev bc\
   --run="pip install --upgrade pip" \
   --run="pip install scikit-image nibabel" \
   --run="git clone https://github.com/braincharter/vasculature.git" \
   --workdir /vasculature/cplusplus_frangi_iter/build \
   --run="sed -i 's/4.9.1/4.9.0/g' ../CMakeLists.txt" \
   --run="ln -s /usr/lib/cli/vtkgdcm-sharp-2.6/libvtkgdcmsharpglue.so /usr/lib/x86_64-linux-gnu/libvtkgdcmsharpglue.so" \
   --run="mkdir -p /usr/lib/python/dist-packages/" \
   --run="ln -s /usr/lib/x86_64-linux-gnu/libvtkgdcmPythonD.so /usr/lib/python/dist-packages/libvtkgdcmPython.so" \
   --run="cmake ../" \
   --run="make " \
   --workdir /vasculature/bin \
   --run="rm /vasculature/itkVEDMain" \
   --run="cp /vasculature/cplusplus_frangi_iter/build/itkVEDMain /vasculature/bin" \
   --env DEPLOY_PATH=/vasculature/bin \
   --env PATH="/vasculature/bin:/opt/afni-latest/:$PATH" \
   --user=neuro \
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
