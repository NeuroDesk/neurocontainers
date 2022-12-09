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
   --base-image ubuntu:18.04 \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir ${mountPointList}" \
   --miniconda version=py37_4.8.3 \
         conda_install='pytorch=1.6.0 torchvision=0.7.0 cudatoolkit=10.2 -c pytorch' \
         pip_install='pandas seaborn nibabel torch-geometric==1.6.3 scikit-learn==0.22.2 scipy==1.1.0 matplotlib==3.2.1' \
   --run='pip install --no-index torch-sparse -f https://pytorch-geometric.com/whl/torch-1.6.0+cu102.html' \
   --run='pip install --no-index torch-scatter -f https://pytorch-geometric.com/whl/torch-1.6.0+cu102.html' \
   --run='pip install --no-index torch-cluster -f https://pytorch-geometric.com/whl/torch-1.6.0+cu102.html' \
   --run='pip install --no-index torch-spline-conv -f https://pytorch-geometric.com/whl/torch-1.6.0+cu102.html' \
   --install git wget connectome-workbench \
   --freesurfer version=7.1.1 \
   --copy license.txt /opt/freesurfer-7.1.1/license.txt \
   --env DEPLOY_BINS=wb_view:wb_command:wb_shortcuts \
   --copy README.md /README.md \
  > ${toolName}_${toolVersion}.Dockerfile

if [ "$1" != "" ]; then
   ./../main_build.sh
fi
