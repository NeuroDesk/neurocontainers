# this template file builds itksnap and is then used as a docker base image for layer caching
export toolName='niftyreg'
export toolVersion='1.4.0' #https://github.com/KCL-BMEIS/niftyreg
# Don't forget to update version change in README.md!!!!!

export commit_sha='8ad2f11507ddedb09ed74a9bd97377b70532ee75'


if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base-image 'ubuntu:20.04' \
   --pkg-manager apt \
   --install libgomp1 ca-certificates curl cmake make g++ \
   --workdir=/opt/${toolName}-${toolVersion} \
   --run="curl -fsSL --retry 5 https://github.com/KCL-BMEIS/niftyreg/archive/${commit_sha}.tar.gz | tar -xz -C ./" \
   --run="mv ${toolName}-${commit_sha} src && mkdir build" \
   --run="cmake -S src -B build -D CMAKE_INSTALL_PREFIX=/opt/${toolName}-${toolVersion}" \
   --run="cd build && make && make install" \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir -p ${mountPointList}" \
   --env TOOLBOX_PATH=/opt/${toolName}-${toolVersion}/ \
   --env PATH=/opt/${toolName}-${toolVersion}/bin:${PATH} \
   --env DEPLOY_PATH=/opt/${toolName}-${toolVersion}/bin/ \
   --copy README.md /README.md \
> ${imageName}.${neurodocker_buildExt} 

if [ "$1" != "" ]; then
   ./../main_build.sh
fi
