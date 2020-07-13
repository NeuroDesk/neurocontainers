#install miniconda
# wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh

#install neurodocker
#pip install --no-cache-dir https://github.com/kaczmarj/neurodocker/tarball/master --user

# install development version
pip install --no-cache-dir https://github.com/NeuroDesk/neurodocker/tarball/master --upgrade

export buildMode='docker'  #docker_local or docker_hub or singularity or docker_singularity

if [ "$debug" = "true" ]; then
    export buildMode='docker_singularity' 
    export testImageDocker='true'
    export localSingularityBuild='true'
    export localSingularityBuildWritable='false'
    export remoteSingularityBuild='false'
    export testImageSingularity='false'
    export uploadToSwift='false'
    export uploadToSylabs='false'
    export cleanupSif='false'
fi

if [ "$buildMode" = "singularity" ]; then
       export neurodocker_buildMode="singularity"
       export neurodocker_buildExt="Singularity"
       echo "generating singularity recipe..."
else
       export neurodocker_buildMode="docker"
       export neurodocker_buildExt="Dockerfile"
       echo "generating docker recipe..."
fi

export buildDate=`date +%Y%m%d`

export imageName=${toolName}_${toolVersion}


echo "building $imageName in mode $buildMode"

export mountPointList=$( cat ../globalMountPointList.txt )

echo "mount points to be created inside image:"
echo $mountPointList
