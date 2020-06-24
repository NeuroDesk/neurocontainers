#install miniconda
# wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh

#install neurodocker
#pip install --no-cache-dir https://github.com/kaczmarj/neurodocker/tarball/master --user

# install development version
pip install --no-cache-dir https://github.com/NeuroDesk/neurodocker/tarball/master --upgrade
# pip install --no-cache-dir https://github.com/NeuroDesk/neurodocker/tarball/mrtrix_git_checkout_fix --upgrade


export buildMode='docker_singularity'  #docker_local or docker_hub or singularity or docker_singularity
export testImageDocker='false'
export localSingularityBuild='true'
export localSingularityBuildWritable='false'
export remoteSingularityBuild='false'
export testImageSingularity='false'
export uploadToSwift='true'
export uploadToSylabs='false'
export cleanupSif='true'


if [ "$buildMode" = "singularity" ]; then
       export neurodocker_buildMode="singularity"
       echo "generating singularity recipe..."
else
       export neurodocker_buildMode="docker"
       echo "generating docker recipe..."
fi

export buildDate=`date +%Y%m%d`

export imageName=${toolName}_${toolVersion}


echo "building $imageName in mode $buildMode" 

export mountPointList=$( cat ../globalMountPointList.txt )

echo "mount points to be created inside image:"
echo $mountPointList
