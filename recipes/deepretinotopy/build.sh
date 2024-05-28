#!/usr/bin/env bash
set -e


export toolName='deepretinotopy'
export toolVersion='1.0.5'
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
         pip_install='packaging pandas==1.1.5 seaborn==0.11.1 nibabel==3.2.1 torch-geometric==1.6.3 scikit-learn==0.22.2 scipy==1.5.4 matplotlib==3.3.4 osfclient==0.0.5' \
   --run='pip install --no-index torch-sparse -f https://pytorch-geometric.com/whl/torch-1.6.0+cu102.html' \
   --run='pip install --no-index torch-scatter -f https://pytorch-geometric.com/whl/torch-1.6.0+cu102.html' \
   --run='pip install --no-index torch-cluster -f https://pytorch-geometric.com/whl/torch-1.6.0+cu102.html' \
   --run='pip install --no-index torch-spline-conv -f https://pytorch-geometric.com/whl/torch-1.6.0+cu102.html' \
   --run='git clone https://github.com/felenitaribeiro/nilearn.git' \
   --workdir=/opt \
   --run='git clone https://github.com/felenitaribeiro/deepRetinotopy_TheToolbox.git && \
       cd deepRetinotopy_TheToolbox && \
       git checkout 629a5dbb2e71eda22b4a83a3b9a2767be2ab82cc' \
   --workdir='/opt/deepRetinotopy_TheToolbox' \
   --run='osf -p ermbz list | while read i; do if [[ ${i:0:10} == "osfstorage" ]]; then path=".${i:10}"; sudo mkdir -p ${path%/*}; sudo chmod 777 ${path%/*}; osf -p ermbz fetch $i ".${i:10}"; echo $i; fi; done' \
   --env PATH=/opt/workbench/workbench/bin_rh_linux64/:/opt/deepRetinotopy_TheToolbox/:'$PATH' \
   --env DEPLOY_BINS="wb_view:wb_command:wb_shortcuts:python:deepRetinotopy:1_native2fsaverage.sh:2_inference.py:3_fsaverage2native.sh" \
   --copy README.md /README.md \
  > ${toolName}_${toolVersion}.Dockerfile

if [ "$1" != "" ]; then
   ./../main_build.sh
fi
