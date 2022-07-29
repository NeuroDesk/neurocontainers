#!/usr/bin/env bash
set -e

export toolName='qsmxtbase'
export toolVersion='1.1.3'
# Don't forget to update version change in README.md!!!!!

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

# Version history:
# - 1.0.0: Release for preprint including FS7, Minc, FSL
# - 1.1.0: Change to Fastsurfer and replace minc with Ants
# - 1.1.1: update Julia and move packages to depot_Path + changed python version to 3.7
# - 1.1.2: changed python version back to 3.6 with older Miniconda version + fixed versions
# - 1.1.3: Removed FSL, bidscoin, matplotlib, seaborn; added bet2
# - 1.1.3 (fix): Fixed dependency problems occuring with Nipype (see github.com/QSMxT/QSMxT/runs/7553737387)

yes | neurodocker generate ${neurodocker_buildMode} \
   --base-image ubuntu:18.04 \
   --pkg-manager apt \
   --env DEBIAN_FRONTEND=noninteractive \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --install bzip2 ca-certificates wget unzip gcc cmake g++ dbus-x11 libgtk2.0-0 git graphviz wget \
      zip libgl1 libglib2.0 libglu1-mesa libsm6 libxrender1 libxt6 libxcomposite1 libfreetype6 \
      libasound2 libfontconfig1 libxkbcommon0 libxcursor1 libxi6 libxrandr2 libxtst6 qt5-default \
      libqt5svg5-dev wget libqt5opengl5-dev libqt5opengl5 libqt5gui5 libqt5core5a \
   --env PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
   --workdir="/opt/TGVQSM" \
   --run="wget https://repo.anaconda.com/miniconda/Miniconda2-4.6.14-Linux-x86_64.sh" \
   --run="bash Miniconda2-4.6.14-Linux-x86_64.sh -b -p miniconda2" \
   --run="miniconda2/bin/conda install -c anaconda cython==0.29.4" \
   --run="miniconda2/bin/conda install numpy" \
   --run="miniconda2/bin/conda install pyparsing" \
   --run="miniconda2/bin/pip install scipy==0.17.1 nibabel==2.1.0" \
   --run="wget http://www.neuroimaging.at/media/qsm/TGVQSM-plus.zip" \
   --run="unzip TGVQSM-plus.zip && rm TGVQSM-plus.zip" \
   --workdir="/opt/TGVQSM/TGVQSM-master-011045626121baa8bfdd6633929974c732ae35e3" \
   --copy setup.py /opt/TGVQSM/TGVQSM-master-011045626121baa8bfdd6633929974c732ae35e3 \
   --env PYTHONPATH=/opt/TGVQSM/TGVQSM-master-011045626121baa8bfdd6633929974c732ae35e3/TGV_QSM \
   --run="/opt/TGVQSM/miniconda2/bin/python setup.py install" \
   --workdir="/opt/TGVQSM/tgvqsm-1.0.0" \
   --run="cp /opt/TGVQSM/miniconda2/bin/tgv_qsm ." \
   --env PATH='$PATH':/opt/TGVQSM/tgvqsm-1.0.0 \
   --workdir="/opt/bet2" \
   --run="git clone https://github.com/liangfu/bet2.git ." \
   --run="cmake . && make" \
   --env PATH='$PATH':/opt/bet2 \
   --env SUBJECTS_DIR=/tmp \
   --ants version=2.3.4 \
   --dcm2niix method=source version=003f0d19f1e57b0129c9dcf3e653f51ca3559028 \
   --miniconda version=4.7.12.1 \
            conda_install='python=3.6 dicomifier scikit-sparse nibabel=2.5.1 pillow=6.2.0 traits=6.2.0 nipype=1.6.0 networkx=2.5 numpy=1.19.4 scipy=1.5.3 h5py=2.10.0 scikit-image=0.17.2' \
   --run="conda install -c pytorch cpuonly "pytorch=1.2.0=py3.6_cpu_0" torchvision=0.4.0=py36_cpu" \
   --run="git clone https://github.com/Deep-MI/FastSurfer.git /opt/FastSurfer" \
   --env FASTSURFER_HOME=/opt/FastSurfer \
   --env PATH='$PATH':/opt/FastSurfer \
   --run="rm -rf /usr/bin/python3.6 && ln -s /opt/miniconda-latest/bin/python /usr/bin/python3.6" \
   --workdir="/opt/bru2" \
   --run="wget https://github.com/neurolabusc/Bru2Nii/releases/download/v1.0.20180303/Bru2_Linux.zip" \
   --run="unzip Bru2_Linux.zip" \
   --env PATH='$PATH':/opt/bru2 \
   --workdir="/opt" \
   --run="wget https://julialang-s3.julialang.org/bin/linux/x64/1.6/julia-1.6.1-linux-x86_64.tar.gz" \
   --run="tar zxvf julia-1.6.1-linux-x86_64.tar.gz" \
   --run="rm -rf julia-1.6.1-linux-x86_64.tar.gz" \
   --env PATH='$PATH':/opt/julia-1.6.1/bin \
   --copy test.sh /test.sh \
  > ${imageName}.${neurodocker_buildExt}

if [ "$1" != "" ]; then
   ./../main_build.sh
fi



# this was necessary in older versions but fails now:
# --run="conda install -c conda-forge dicomifier scikit-sparse nibabel=2.5.1 pillow=7.1.1" \
