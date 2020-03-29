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
#pip install --no-cache-dir https://github.com/stebo85/neurodocker/tarball/master --upgrade


neurodocker generate docker \
   --base=ubuntu:xenial \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --copy globalMountPointList.txt /globalMountPointList.txt \
   --run="mkdir \`cat /globalMountPointList.txt\`" \
   --install wget libc6 libstdc++6 imagemagick perl octave bc libxi6  libxmu6  libjpeg8  libgl1-mesa-glx libglu1-mesa ed libxml2-dev libcurl4-openssl-dev libssl-dev \
   --workdir / \
   --run="wget http://packages.bic.mni.mcgill.ca/minc-toolkit/Debian/minc-toolkit-1.9.16-20180117-Ubuntu_16.04-x86_64.deb" \
   --run="dpkg -i /minc-toolkit-1.9.16-20180117-Ubuntu_16.04-x86_64.deb" \
   --run="rm /minc-toolkit-1.9.16-20180117-Ubuntu_16.04-x86_64.deb" \
   --run="cp /opt/minc/1.9.16/bin/bestlinreg.pl /opt/minc/1.9.16/bin/bestlinreg" \
   --user=neuro \
   --env DEPLOY_PATH=/opt/minc/1.9.16/bin/ \
   --env MINC_TOOLKIT=/opt/minc/1.9.16/ \
   --env MINC_TOOLKIT_VERSION="1.9.16-20180117" \
   --env PATH="/opt/minc/1.9.16/bin:/opt/minc/1.9.16/pipeline:$PATH" \
   --env PERL5LIB="/opt/minc/1.9.16/perl:/opt/minc/1.9.16/pipeline:$PERL5LIB" \
   --env LD_LIBRARY_PATH="/opt/minc/1.9.16/lib:/opt/minc/1.9.16/lib/InsightToolkit:$LD_LIBRARY_PATH" \
   --env MNI_DATAPATH=/opt/minc/1.9.16/../share \
   --env MINC_FORCE_V2="1" \
   --env MINC_COMPRESS="4" \
   --env VOLUME_CACHE_THRESHOLD="-1" \
   --env MANPATH="/opt/minc/1.9.16/man:$MANPATH" \
   --env ANTSPATH=/opt/minc/1.9.16/bin/ \
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
