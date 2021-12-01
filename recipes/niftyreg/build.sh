# this template file builds itksnap and is then used as a docker base image for layer caching
export toolName='niftyreg'
export toolVersion='1.4.0'
# Don't forget to update version change in README.md!!!!!

export commit_sha='83d8d1182ed4c227ce4764f1fdab3b1797eecd8d'


if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug="true"
fi

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base-image 'ubuntu:20.04' \
   --pkg-manager apt \
   --install apt_opts="--quiet" ca-certificates curl cmake make g++ \
   --workdir=/opt/builder/ \
   --run="curl -fsSL --retry 5 https://github.com/KCL-BMEIS/niftyreg/archive/${commit_sha}.tar.gz | tar -xz -C ./" \
   --run="mv ${toolName}-${commit_sha} src && mkdir build" \
   --run="cmake -S src -B build -D CMAKE_INSTALL_PREFIX=/opt/${toolName}-${toolVersion}" \
   --run="cd build && make && make install" \
   --base-image 'ubuntu:20.04' \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir ${mountPointList}" \
   --copy-from '0' /opt/${toolName}-${toolVersion} /opt/${toolName}-${toolVersion} \
   --workdir=/opt/${toolName}-${toolVersion} \
   --install apt_opts="--quiet" libgomp1 \
   --env TOOLBOX_PATH=/opt/${toolName}-${toolVersion}/ \
   --env PATH=/opt/${toolName}-${toolVersion}:${PATH} \
   --env DEPLOY_PATH=/opt/${toolName}-${toolVersion}/bin/ \
   --copy README.md /README.md \
  > ${toolName}_${toolVersion}.Dockerfile

if [ "$debug" = "true" ]; then
   ./../main_build.sh
fi
