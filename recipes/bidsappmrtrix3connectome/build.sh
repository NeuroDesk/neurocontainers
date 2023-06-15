export toolName='bidsappmrtrix3connectome'
# toolName or toolVersion CANNOT contain capital letters or dashes or underscores (Docker registry does not accept this!)

export toolVersion='0.5.3' 
# the version number cannot contain a "-" - try to use x.x.x notation always
# https://hub.docker.com/r/bids/mrtrix3_connectome/tags

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base-image bids/mrtrix3_connectome:${toolVersion} \
   --env DEBIAN_FRONTEND=noninteractive \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir -p ${mountPointList}" \
   --env PATH='$PATH':/ \
   --env DEPLOY_PATH=/opt/mrtrix3/bin:/usr/lib/ants:/opt/freesurfer/bin:/opt/freesurfer/mni/bin:/opt/fsl/bin:/opt/ROBEX:/ \
   --copy README.md /README.md \
   --entrypoint bash \
  > ${imageName}.${neurodocker_buildExt}


if [ "$1" != "" ]; then
   ./../main_build.sh
fi

# This container wastes 4gb of space due to 
# Wasted Space  File Path
   #  2        452 MB  /opt/fsl/fslpython/pkgs/mkl-2020.4-h726a3e6_304.tar.bz2
   #  2        412 MB  /opt/fsl/fslpython/pkgs/cache/497deca9.json
   #  2        303 MB  /opt/fsl/fslpython/pkgs/cache/497deca9.q
   #  2        208 MB  /opt/fsl/fslpython/pkgs/qt-5.12.5-hd8c4c69_1.tar.bz2
   #  2        205 MB  /opt/fsl/fslpython/pkgs/tirl-2.1.3b1-py37ha8d69ae_0.tar.bz2
   #  2        130 MB  /opt/fsl/fslpython/pkgs/cache/09cdf8bf.json
   #  2        111 MB  /opt/fsl/fslpython/pkgs/python-3.7.6-cpython_h8356626_6.tar.bz2
   #  2         93 MB  /opt/fsl/fslpython/pkgs/cache/09cdf8bf.q
   #  2         82 MB  /opt/fsl/fslpython/pkgs/vtk-8.2.0-py37h2bd422c_218.tar.bz2
   #  2         74 MB  /usr/lib/x86_64-linux-gnu/libLLVM-10.so.1
   #  2         72 MB  /opt/fsl/fslpython/pkgs/libopencv-4.5.2-py37h8945300_0.tar.bz2
   #  2         68 MB  /opt/fsl/fslpython/pkgs/cache/47929eba.json
   #  2         58 MB  /opt/fsl/fslpython/pkgs/fsleyes-0.34.2-py37h89c1867_2.tar.bz2
   #  2         56 MB  /opt/fsl/fslpython/pkgs/libllvm10-10.0.1-he513fc3_3.tar.bz2