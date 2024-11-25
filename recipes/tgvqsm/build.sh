#!/usr/bin/env bash
set -e

export toolName='tgvqsm'
export toolVersion='1.0.0'
# Don't forget to update version change in README.md!!!!!

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base-image ubuntu:16.04 \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir -p ${mountPointList}" \
   --install opts="--quiet" wget unzip gcc cmake git g++ \
   --run="git clone https://github.com/liangfu/bet2.git" \
   --workdir /bet2/build \
   --run="cmake .. && make" \
   --dcm2niix version=latest method=source \
   --workdir / \
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
   --run="/miniconda2/bin/python setup.py install" \
   --workdir="/opt/${toolName}-${toolVersion}" \
   --run="cp /miniconda2/bin/tgv_qsm ." \
   --copy README.md /README.md \
   --env DEPLOY_PATH=/opt/${toolName}-${toolVersion}/:/bet2/:/opt/dcm2niix-latest/bin \
  > ${imageName}.${neurodocker_buildExt}

if [ "$1" != "" ]; then
   ./../main_build.sh
fi


