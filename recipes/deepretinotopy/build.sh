#!/usr/bin/env bash
set -e


export toolName='deepretinotopy'
export toolVersion='1.0.1'
# Don't forget to update version change in README.md!!!!!

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base-image ghcr.io/neurodesk/freesurfer_7.3.2:20230216 \
   --pkg-manager yum \
   --install git \
   --miniconda version=py37_4.8.3 \
         conda_install='pytorch=1.6.0 torchvision=0.7.0 cudatoolkit=10.2 -c pytorch' \
         pip_install='packaging pandas seaborn nibabel torch-geometric==1.6.3 scikit-learn==0.22.2 scipy==1.1.0 matplotlib==3.2.1' \
   --run='pip install --no-index torch-sparse -f https://pytorch-geometric.com/whl/torch-1.6.0+cu102.html' \
   --run='pip install --no-index torch-scatter -f https://pytorch-geometric.com/whl/torch-1.6.0+cu102.html' \
   --run='pip install --no-index torch-cluster -f https://pytorch-geometric.com/whl/torch-1.6.0+cu102.html' \
   --run='pip install --no-index torch-spline-conv -f https://pytorch-geometric.com/whl/torch-1.6.0+cu102.html' \
   --run='git clone https://github.com/felenitaribeiro/nilearn.git' \
   --env DEPLOY_BINS=wb_view:wb_command:wb_shortcuts \
   --copy README.md /README.md \
  > ${toolName}_${toolVersion}.Dockerfile

if [ "$1" != "" ]; then
   ./../main_build.sh
fi
