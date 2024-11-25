#!/usr/bin/env bash
set -e
export toolName='fastcsr'
export toolVersion='1.0'
# https://github.com/IndiLab/FastCSR/tree/main 

if [ "$1" != "" ]; then
echo "Entering Debug mode"
export debug=$1
fi
 
source ../main_setup.sh
 
neurodocker generate ${neurodocker_buildMode} \
--base-image ubuntu:20.04 \
--pkg-manager apt \
--env DEBIAN_FRONTEND=noninteractive \
--run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
--run="chmod +x /usr/bin/ll" \
--run="mkdir -p ${mountPointList}" \
--install opts=--quiet git software-properties-common wget openjdk-11-jdk bc binutils libgomp1 perl psmisc sudo tar tcsh unzip uuid-dev vim-common libjpeg62-dev python3-pip \
--freesurfer version=6.0.0 \
--copy fs_license.txt /opt/freesurfer-6.0.0/license.txt \
--env LD_LIBRARY_PATH=/usr/lib/jvm/java-11-openjdk-amd64/lib:/usr/lib/jvm/java-11-openjdk-amd64/lib/server \
--run='wget https://github.com/IndiLab/FastCSR/blob/main/docker/nighres-1.5.0-cp38-cp38-linux_x86_64.whl?raw=true -O /opt/nighres-1.5.0-cp38-cp38-linux_x86_64.whl \
    && pip3 install /opt/nighres-1.5.0-cp38-cp38-linux_x86_64.whl \
    && rm -rf /opt/nighres-1.5.0-cp38-cp38-linux_x86_64.whl' \
--run='pip install nighres==1.5.0' \
--run='pip install -U numpy' \
--run='pip install torch==1.9.1+cpu torchvision==0.10.1+cpu torchaudio==0.9.1 -f https://download.pytorch.org/whl/torch_stable.html' \
--env SKLEARN_ALLOW_DEPRECATED_SKLEARN_PACKAGE_INSTALL=True \
--run='pip install nnunet==1.7.1 antspyx sh' \
--workdir /opt \
--run='git clone https://github.com/IndiLab/FastCSR.git' \
--workdir /opt/FastCSR/ \
--run='wget "https://drive.usercontent.google.com/download?id=1qATJ2PT8e6RhBnfJviU6qTtBicVO9_Qr&export=download&authuser=0&confirm=t&uuid=ba0ee838-2af9-48be-8a27-39e5475e4802&at=APZUnTWLoGPK9o4jOoHb5vxdbqCf:1698212871026" -O /opt/FastCSR/model.zip \
    && unzip /opt/FastCSR/model.zip \
    && rm /opt/FastCSR/model.zip' \
--run='wget "https://drive.usercontent.google.com/download?id=1Ypw25hbpCloQzlbWhg1XWB-HuxIVlHH7&export=download&authuser=0&confirm=t&uuid=e00becd7-c885-4748-8099-04f472d7ccdd&at=APZUnTX9F-JDE6TLLHxD2NuSF0pA:1698212916237" -O /opt/FastCSR/data.zip \
    && unzip /opt/FastCSR/data.zip \
    && rm /opt/FastCSR/data.zip' \
--copy README.md /README.md \
--copy license.txt /license.txt \
> ${toolName}_${toolVersion}.Dockerfile 


if [ "$1" != "" ]; then 
./../main_build.sh 
fi


#numpy               1.16.4              is not compatible: 