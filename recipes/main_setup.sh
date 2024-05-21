#install miniconda
# wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh

#install neurodocker
#pip install --no-cache-dir https://github.com/kaczmarj/neurodocker/tarball/master --user

# install development version
yes | pip uninstall neurodocker
python -m pip install --no-cache-dir https://github.com/ReproNim/neurodocker/tarball/master --upgrade

export PATH=$PATH:~/.local/bin

export buildMode='docker'  #docker_local or docker_hub or singularity or docker_singularity

# debug mode is for testing docker + singularity
if [ "$debug" = "-ds" ]; then
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

# dev mode is for just running singularity (e.g when building on neurodesk itself)
if [ "$debug" = "-s" ]; then
       export buildMode='singularity' 
       export testImageDocker='false'
       export localSingularityBuild='true'
       export localSingularityBuildWritable='false'
       export remoteSingularityBuild='false'
       export testImageSingularity='true'
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

# If TinyRange exists in the expected location then enable it.
if test -f /storage/tinyrange/tinyrange; then
       export TINYRANGE=/storage/tinyrange/tinyrange
elif command -v tinyrange &> /dev/null; then
       export TINYRANGE=tinyrange
fi

echo "building $imageName in mode $buildMode"

export mountPointList=$( cat ../globalMountPointList.txt )

echo "mount points to be created inside image:"
echo $mountPointList
