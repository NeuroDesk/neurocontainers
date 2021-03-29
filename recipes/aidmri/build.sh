# this template file builds itksnap and is then used as a docker base image for layer caching
export toolName='aidmri'
export toolVersion='1.1'
export niftyreg_commit_sha='83d8d1182ed4c227ce4764f1fdab3b1797eecd8d'

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug="true"
fi

source ../main_setup.sh

#TODO Add dsistudio
neurodocker generate ${neurodocker_buildMode} \
   --base dsistudio/dsistudio:latest \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir ${mountPointList}" \
   --fsl version=6.0.4 exclude_paths='data' \
   --install apt_opts="--quiet" wget unzip cmake make g++ \
   --workdir=/opt \
   --run="wget --no-check-certificate https://github.com/aswendtlab/AIDAmri/archive/master.zip" \
   --run="unzip AIDAmri-master.zip && rm AIDAmri-master.zip && mv AIDAmri-master src" \
   --run="mv src/bin ./ && src/lib ./ && rm -rf src" \
   --workdir=/opt/${toolName}-${toolVersion}/niftyreg \
   --run="wget --no-check-certificate https://github.com/CAIsr/niftyreg/archive/${niftyreg_commit_sha}.zip" \
   --run="unzip ${niftyreg_commit_sha}.zip && rm ${niftyreg_commit_sha}.zip && mv niftyreg-${niftyreg_commit_sha} src" \
   --run="mkdir -p build ${toolName}-${toolVersion}" \
   --run="cmake -S src -B build -D CMAKE_INSTALL_PREFIX=/opt/${toolName}-${toolVersion}/niftyreg" \
   --run="cd build && make && make install" \
   --run="rm -rf build src" \
   --env TOOLBOX_PATH=/opt/${toolName}-${toolVersion}/ \
   --env PATH=/opt/${toolName}-${toolVersion}:${PATH} \
   --env DEPLOY_PATH=/opt/${toolName}-${toolVersion}/bin/:/opt/${toolName}-${toolVersion}/niftyreg/bin/ \
   --env DEPLOY_BINS=dsi_studio:fsleyes \
   --copy README.md /README.md \
  > ${toolName}_${toolVersion}.Dockerfile

if [ "$debug" = "true" ]; then
   ./../main_build.sh
fi
