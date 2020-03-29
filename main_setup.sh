
#install neurodocker
#pip install --no-cache-dir https://github.com/kaczmarj/neurodocker/tarball/master --user

#upgrade neurodocker
#pip install --no-cache-dir https://github.com/kaczmarj/neurodocker/tarball/master --upgrade

# install development version
# pip install --no-cache-dir https://github.com/stebo85/neurodocker/tarball/master --upgrade


export buildMode='singularity'  #singularity or docker_singularity
export testImageDocker='false'
export localSingularityBuild='true'
export remoteSingularityBuild='false'
export testImageSingularity='false'
export uploadToSwift='true'
export uploadToSylabs='true'


if [ "$buildMode" = "singularity" ]; then
       export neurodocker_buildMode="singularity"
       echo "generating singularity recipe..."
else
       export neurodocker_buildMode="docker"
       echo "generating docker recipe..."
fi

export buildDate=`date +%Y%m%d`


echo "building $imageName in mode $buildMode" 

export mountPointList=$( cat globalMountPointList.txt )

echo "mount points to be created inside image:"
echo $mountPointList