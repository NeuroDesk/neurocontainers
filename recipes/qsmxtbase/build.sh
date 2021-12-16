#!/usr/bin/env bash
set -e

export toolName='qsmxtbase'
export toolVersion='1.1.1'
# Don't forget to update version change in README.md!!!!!

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug="true"
fi

source ../main_setup.sh

# Version history:
# - 1.0.0: Release for preprint including FS7, Minc, FSL
# - 1.1.0: Change to Fastsurfer and replace minc with Ants
# - 1.1.1: update Julia and move packages to depot_Path

# this should fix the octave bug caused by fsl installing openblas:
# apt update
# apt install liblapack-dev liblas-dev
# update-alternatives --set libblas.so.3-x86_64-linux-gnu /usr/lib/x86_64-linux-gnu/blas/libblas.so.3
# update-alternatives --set liblapack.so.3-x86_64-linux-gnu /usr/lib/x86_64-linux-gnu/lapack/liblapack.so.3


yes | neurodocker generate ${neurodocker_buildMode} \
   --base-image ubuntu:18.04 \
   --pkg-manager apt \
   --env DEBIAN_FRONTEND=noninteractive \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir -p ${mountPointList}" \
   --install bzip2 ca-certificates wget unzip gcc dbus-x11 libgtk2.0-0 git graphviz wget \
      zip libgl1 libglib2.0 libglu1-mesa libsm6 libxrender1 libxt6 libxcomposite1 libfreetype6 \
      libasound2 libfontconfig1 libxkbcommon0 libxcursor1 libxi6 libxrandr2 libxtst6 qt5-default \
      libqt5svg5-dev wget libqt5opengl5-dev libqt5opengl5 libqt5gui5 libqt5core5a \
   --run="wget https://repo.anaconda.com/miniconda/Miniconda2-4.6.14-Linux-x86_64.sh" \
   --env PATH=/miniconda2/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
   --run="bash Miniconda2-4.6.14-Linux-x86_64.sh -b -p /miniconda2/" \
   --run="/miniconda2/bin/conda install -c anaconda cython==0.29.14" \
   --run="/miniconda2/bin/conda install numpy" \
   --run="/miniconda2/bin/conda install pyparsing" \
   --run="/miniconda2/bin/pip install scipy==0.17.1 nibabel==2.1.0" \
   --run="wget http://www.neuroimaging.at/media/qsm/TGVQSM-plus.zip" \
   --run="unzip TGVQSM-plus.zip" \
   --workdir="/TGVQSM-master-011045626121baa8bfdd6633929974c732ae35e3" \
   --copy setup.py /TGVQSM-master-011045626121baa8bfdd6633929974c732ae35e3 \
   --env PYTHONPATH=/TGVQSM-master-011045626121baa8bfdd6633929974c732ae35e3/TGV_QSM \
   --run="/miniconda2/bin/python setup.py install" \
   --workdir="/opt/tgvqsm-1.0.0" \
   --run="cp /miniconda2/bin/tgv_qsm ." \
   --fsl version=6.0.4 exclude_paths='data' \
   --env SUBJECTS_DIR=/tmp \
   --ants version=2.3.4 \
   --dcm2niix method=source version=latest \
   --workdir /opt/bru2 \
   --miniconda version=latest \
            conda_install='python=3.7 dicomifier scikit-sparse nibabel=2.5.1 pillow=7.1.1 seaborn=0.11.1 traits=6.2.0 nipype=1.6.0 numpy=1.19.4 scipy=1.5.3 matplotlib=3.3.4 h5py=2.10.0 scikit-image=0.17.2' \
            pip_install='bidscoin' \
   --run="conda install -c pytorch cpuonly "pytorch=1.2.0=py3.7_cpu_0" torchvision=0.4.0=py37_cpu" \
   --run="git clone https://github.com/Deep-MI/FastSurfer.git /opt/FastSurfer" \
   --run="wget https://github.com/neurolabusc/Bru2Nii/releases/download/v1.0.20180303/Bru2_Linux.zip" \
   --run="unzip Bru2_Linux.zip" \
   --workdir /opt \
   --run="wget https://julialang-s3.julialang.org/bin/linux/x64/1.6/julia-1.6.1-linux-x86_64.tar.gz" \
   --run="tar zxvf julia-1.6.1-linux-x86_64.tar.gz" \
   --run="rm -rf julia-1.6.1-linux-x86_64.tar.gz" \
   --env PATH='$PATH':/opt/julia-1.6.1/bin \
   --install liblapack-dev liblas-dev \
   --run="update-alternatives --set libblas.so.3-x86_64-linux-gnu /usr/lib/x86_64-linux-gnu/blas/libblas.so.3" \
   --run="update-alternatives --set liblapack.so.3-x86_64-linux-gnu /usr/lib/x86_64-linux-gnu/lapack/liblapack.so.3" \
   --env FASTSURFER_HOME=/opt/FastSurfer \
  > ${imageName}.Dockerfile
   # --run="conda install -c conda-forge dicomifier scikit-sparse nibabel=2.5.1 pillow=7.1.1" \

if [ "$debug" = "true" ]; then
   ./../main_build.sh
fi

#wget https://files.au-1.osf.io/v1/resources/bt4ez/providers/osfstorage/5e9bf3ab430166067ea05564?action=download&direct&version=1
#mv 5e9bf3ab430166067ea05564\?action\=download test.nii.gz
#./run_fastsurfer.sh --t1 /opt/FastSurfer/test.nii.gz --sid test --seg_only