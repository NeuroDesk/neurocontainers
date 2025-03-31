#!/usr/bin/env bash
set -e


export toolName='deepretinotopy'
export toolVersion='1.0.9'
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
   --run="mkdir -p ${mountPointList}" \
   --miniconda version=latest \
         conda_install='python=3.12.8' \
         pip_install='packaging osfclient==0.0.5 nibabel' \
   --run='pip3 install torch==2.5.1 torchvision --index-url https://download.pytorch.org/whl/cpu' \
   --run='pip install torch_geometric==2.6.1' \
   --run='pip install torch_scatter torch_sparse torch_cluster torch_spline_conv -f https://data.pyg.org/whl/torch-2.5.1+cpu.html' \
   --run='python -c "import torch" 2>/dev/null || { echo "Failed to import module"; exit 1; }' \
   --workdir=/opt \
   --run='git clone https://github.com/felenitaribeiro/deepRetinotopy_TheToolbox.git && \
       cd deepRetinotopy_TheToolbox && \
       git checkout 51437f47db4153bb21a9370be758aaad2fe15eb6 && \
       files_to_download=("osfstorage/new_models/deepRetinotopy_polarAngle_LH_model5.pt" "osfstorage/new_models/deepRetinotopy_eccentricity_LH_model2.pt" "osfstorage/new_models/deepRetinotopy_pRFsize_LH_model5.pt" "osfstorage/new_models/deepRetinotopy_polarAngle_RH_model4.pt" "osfstorage/new_models/deepRetinotopy_eccentricity_RH_model2.pt" "osfstorage/new_models/deepRetinotopy_pRFsize_RH_model5.pt") && \
       for file in "${files_to_download[@]}"; do path="${file:15}"; mkdir -p "${path%/*}"; chmod 777 "${path%/*}"; osf -p ermbz fetch "$file" "$path"; echo "$file"; new_path=$(echo "$path" | sed -E 's/model[0-9]+/model/'); mv "$path" "$new_path"; echo "Renamed $path to $new_path"; done' \
   --workdir='/opt/deepRetinotopy_TheToolbox' \
   --env PATH=/opt/workbench/workbench/bin_rh_linux64/:/opt/deepRetinotopy_TheToolbox/:/opt/deepRetinotopy_TheToolbox/main/:/opt/deepRetinotopy_TheToolbox/utils/:'$PATH' \
   --env DEPLOY_BINS="wb_view:wb_command:wb_shortcuts:python:deepRetinotopy:signMaps:1_native2fsaverage.sh:2_inference.py:3_fsaverage2native.sh:4_signmaps.py:transform_polarangle_lh.py:midthickness_surf.py" \
   --copy README.md /README.md \
  > ${toolName}_${toolVersion}.Dockerfile
 

#this is needed because neurodocker adds localedef, but this is not supported for all base images
sed -i '/localedef/d' ${toolName}_${toolVersion}.Dockerfile

if [ "$1" != "" ]; then
   ./../main_build.sh
fi