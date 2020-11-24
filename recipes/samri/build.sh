#!/usr/bin/env bash
set -e

# this template file builds spm12
export toolName='samri'
export toolVersion='0.5'

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug="true"
fi

source ../main_setup.sh

echo "FROM gentoo/stage3" > ${toolName}_${toolVersion}.Dockerfile
# echo "RUN printf '#!/bin/bash\nls -la' > /usr/bin/ll" >> ${toolName}_${toolVersion}.Dockerfile
# echo "RUN chmod +x /usr/bin/ll" >> ${toolName}_${toolVersion}.Dockerfile
# echo "RUN mkdir ${mountPointList}" >> ${toolName}_${toolVersion}.Dockerfile
echo "RUN emerge --sync" >> ${toolName}_${toolVersion}.Dockerfile
echo "RUN emerge --verbose dev-vcs/git" >> ${toolName}_${toolVersion}.Dockerfile
echo "WORKDIR /etc/portage/repos.conf/" >> ${toolName}_${toolVersion}.Dockerfile
echo "RUN wget https://gitweb.gentoo.org/proj/sci.git/plain/metadata/science.conf -O /etc/portage/repos.conf/science" >> ${toolName}_${toolVersion}.Dockerfile
echo "RUN emaint sync --repo science" >> ${toolName}_${toolVersion}.Dockerfile
# echo "WORKDIR /etc/portage/package.accept_keywords/" >> ${toolName}_${toolVersion}.Dockerfile
# echo "RUN printf '*/*::science ~%s' "$(portageq envvar ARCH)" >> /etc/portage/package.accept_keywords/SCIENCE" >> ${toolName}_${toolVersion}.Dockerfile
# echo "RUN printf '*/*::gentoo ~%s' "$(portageq envvar ARCH)" >> /etc/portage/package.accept_keywords/GENTOO" >> ${toolName}_${toolVersion}.Dockerfile
echo "RUN echo 'ACCEPT_KEYWORDS=\"~amd64\"' >> /etc/portage/make.conf" >> ${toolName}_${toolVersion}.Dockerfile
echo "RUN  emerge --sync" >> ${toolName}_${toolVersion}.Dockerfile
echo "RUN  emerge -vaDNu world" >> ${toolName}_${toolVersion}.Dockerfile
echo "RUN emerge -v samri --autounmask-continue" >> ${toolName}_${toolVersion}.Dockerfile

# https://github.com/IBT-FMI/SAMRI/issues/102/ 


# neurodocker generate ${neurodocker_buildMode} \
#    --base centos:7 \
#    --pkg-manager yum \
#    --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
#    --run="chmod +x /usr/bin/ll" \
#    --run="mkdir ${mountPointList}" \
#    --install apt_opts='--quiet' wget git gcc g++ \
#    --workdir /opt \
#    --workdir /opt/samri \
#    --workdir /opt/gentoo \
#    --run="chmod a+rwx /opt/samri" \
#    --run="chmod a+rwx /opt/gentoo" \
#    --user=neuro \
#    --run="wget https://gitweb.gentoo.org/repo/proj/prefix.git/plain/scripts/bootstrap-prefix.sh" \
#    --run="chmod +x bootstrap-prefix.sh" \
#    --workdir /opt/samri \
#    --env DEPLOY_BINS=SAMRI \
#    --copy README.md /README.md \
#   > ${toolName}_${toolVersion}.Dockerfile

if [ "$debug" = "true" ]; then
   ./../main_build.sh
fi
   # --run="./bootstrap-prefix.sh" \

   # --workdir /opt/samri \
   # --run="git clone https://github.com/IBT-FMI/SAMRI.git" \
   # --run="git fetch --all --tags" \
   # --run="git checkout tags/${toolVersion} -b ${toolVersion}-branch" \
   # --run="cd SAMRI/.gentoo" \
   # --run="./install.sh" \