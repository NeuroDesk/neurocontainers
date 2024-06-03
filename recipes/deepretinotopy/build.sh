#!/usr/bin/env bash
set -e


export toolName='deepretinotopy'
export toolVersion='1.0.6'
# Don't forget to update version change in README.md!!!!!


if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base-image ghcr.io/neurodesk/deepretinotopy_1.0.2:20231223 \
   --pkg-manager yum \
   --install git \
   --run='python -c "import torch" 2>/dev/null || { echo "Failed to import module"; exit 1; }' \
   --workdir=/opt \
   --run='cd deepRetinotopy_TheToolbox && \
       git checkout 7411bed5c7a25f5beb165699f38f759b3adc90b6' \
   --workdir='/opt/deepRetinotopy_TheToolbox' \
   # --run='osf -p ermbz list | while read i; do if [[ ${i:0:10} == "osfstorage" ]]; then path=".${i:10}"; sudo mkdir -p ${path%/*}; sudo chmod 777 ${path%/*}; osf -p ermbz fetch $i ".${i:10}"; echo $i; fi; done' \
   --env PATH=/opt/workbench/workbench/bin_rh_linux64/:/opt/deepRetinotopy_TheToolbox/:'$PATH' \
   --env DEPLOY_BINS="wb_view:wb_command:wb_shortcuts:python:deepRetinotopy:1_native2fsaverage.sh:2_inference.py:3_fsaverage2native.sh" \
   --copy README.md /README.md \
  > ${toolName}_${toolVersion}.Dockerfile

if [ "$1" != "" ]; then
   ./../main_build.sh
fi

# Previously installed in the base image
#    --miniconda version=py37_4.8.3 \
#          conda_install='pytorch=1.6.0 torchvision=0.7.0 cudatoolkit=10.2 -c pytorch' \
#          pip_install='packaging pip==23.3.2 future==0.18.3 packaging==23.2 pyparsing==3.1.1 pandas==1.1.5 seaborn==0.11.1 nibabel==3.2.1 torch-geometric==1.6.3 scikit-learn==0.22.2 scipy==1.5.4 matplotlib==3.3.4 osfclient==0.0.5' \
#    --run='pip install --no-index torch-sparse -f https://pytorch-geometric.com/whl/torch-1.6.0+cu102.html' \
#    --run='pip install --no-index torch-scatter -f https://pytorch-geometric.com/whl/torch-1.6.0+cu102.html' \
#    --run='pip install --no-index torch-cluster -f https://pytorch-geometric.com/whl/torch-1.6.0+cu102.html' \
#    --run='pip install --no-index torch-spline-conv -f https://pytorch-geometric.com/whl/torch-1.6.0+cu102.html' \
#    --run='git clone https://github.com/felenitaribeiro/nilearn.git' \
#    --run='rm -rf deepRetinotopy_TheToolbox' \
