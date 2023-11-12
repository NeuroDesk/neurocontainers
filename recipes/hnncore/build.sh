#!/usr/bin/env bash
set -e
export toolName='hnncore'
export toolVersion='0.3'
 
if [ "$1" != "" ]; then
echo "Entering Debug mode"
export debug=$1
fi
 
source ../main_setup.sh
 
neurodocker generate ${neurodocker_buildMode} \
--base-image ubuntu:22.04 \
--pkg-manager apt \
--env DEBIAN_FRONTEND=noninteractive \
--install  \
--run='apt-get install python3.9 python3-pip -y' \
--run='apt-get install openmpi-bin openmpi-doc libopenmpi-dev -y' \
--run='pip install numpy scipy matplotlib NEURON' \
--run='pip install ipywidgets voila scikit-learn joblib mpi4py psutil' \
--run='pip install hnn_core hnn_core[opt] hnn_core[gui]' \
--copy README.md /README.md \
> ${toolName}_${toolVersion}.Dockerfile 
if [ "$1" != "" ]; then 
./../main_build.sh 
fi

