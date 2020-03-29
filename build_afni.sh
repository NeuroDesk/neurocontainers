#!/usr/bin/env bash
set -e

# https://afni.nimh.nih.gov/
export imageName='afni_20p0p23'
export buildDate=`date +%Y%m%d`

export buildMode='docker_singularity'  #singularity or docker_singularity
export localBuild='true'
export remoteBuild='true'
export uploadToSwift='true'
export testImageDocker='true'
export testImageSingularity='false'

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
   --afni version=latest \
   --env DEPLOY_PATH=/opt/afni-latest/bin/ \
   --user=neuro \
  > recipe.${imageName}

./main_build.sh
