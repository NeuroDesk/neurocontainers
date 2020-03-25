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

neurodocker generate singularity \
   --base debian:wheezy \
   --pkg-manager apt \
   --fsl version=6.0.3 \
  > Singularity.${imageName}

#   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
#   --run="chmod +x /usr/bin/ll" \
#   --copy globalMountPointList.txt /globalMountPointList.txt \
#   --run="mkdir \`cat /globalMountPointList.txt\`" \
#   --env FSLOUTPUTTYPE=NIFTI_GZ \
#   --env DEPLOY_PATH=/opt/fsl-6.0.3/bin/ \
#   --user=neuro \

if [ -f ${imageName}_${buildDate}.simg ] ; then
       rm ${imageName}_${buildDate}.simg
fi

sudo singularity build ${imageName}_${buildDate}.simg Singularity.${imageName}

# test:
sudo singularity shell --bind $PWD:/data ${imageName}_${buildDate}.simg

source ../setupSwift.sh
swift upload singularityImages ${imageName}_${buildDate}.simg

git commit -am 'auto commit after build run'
git push
