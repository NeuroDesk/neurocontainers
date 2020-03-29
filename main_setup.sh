
#install neurodocker
#pip install --no-cache-dir https://github.com/kaczmarj/neurodocker/tarball/master --user

#upgrade neurodocker
#pip install --no-cache-dir https://github.com/kaczmarj/neurodocker/tarball/master --upgrade

# install development version
# pip install --no-cache-dir https://github.com/stebo85/neurodocker/tarball/master --upgrade


export buildMode='docker_singularity'  #singularity or docker_singularity
export localBuild='true'
export remoteBuild='true'
export uploadToSwift='true'
export testImageDocker='false'
export testImageSingularity='false'

if [ "$buildMode" = "singularity" ]; then
       export neurodocker_buildMode="singularity"
else
       export neurodocker_buildMode="docker"
fi

export buildDate=`date +%Y%m%d`


echo "building $imageName in mode $buildMode" 

export mountPointList=$( cat globalMountPointList.txt )

echo "mount points to be created inside image:"
echo $mountPointList