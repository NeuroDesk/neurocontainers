#!/usr/bin/env bash
set -e

export imageName='fsl_6p0p3'
export buildDate=`date +%Y%m%d`

buildMode='docker_singularity'  #singularity or docker_singularity
localBuild='true'
uploadToSwift='true'
testImageSingularity='false'
testImageDocker='false'

if [ "$buildMode" = "singularity" ]; then
       neurodocker_buildMode="singularity"
else
       neurodocker_buildMode="docker"
fi

echo "building $imageName in mode $buildMode" 

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

./main_build.sh
