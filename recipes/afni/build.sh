#!/usr/bin/env bash
set -e

export toolName='afni'
export toolVersion='24.2.07'
# https://hub.docker.com/r/afni/afni_make_build/tags

if [ "$1" != "" ]; then
   echo "Entering Debug mode"
   export debug=$1
fi

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base-image ubuntu:24.04 \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir -p ${mountPointList}" \
   --env DEPLOY_PATH=/opt/afni-latest/ \
   --install software-properties-common \
   --run="add-apt-repository universe -y" \
   --install opts=--quit libgdal-dev libopenblas-dev libnode-dev libudunits2-dev r-base r-base-dev tcsh xfonts-base libssl-dev python-is-python3 python3-matplotlib python3-numpy python3-flask python3-flask-cors python3-pil gsl-bin netpbm gnome-tweaks libjpeg62 xvfb xterm vim curl gedit evince eog libglu1-mesa-dev libglw1-mesa-dev libxm4 build-essential libcurl4-openssl-dev libxml2-dev libgfortran-14-dev libgomp1 gnome-terminal nautilus firefox xfonts-100dpi r-base-dev cmake bc libxext-dev libxmu-dev libxpm-dev libgsl-dev libglut-dev libxi-dev libglib2.0-dev \
   --workdir /opt \
   --run="curl -O https://afni.nimh.nih.gov/pub/dist/tgz/linux_ubuntu_24_64.tgz \
         && tar -xf linux_ubuntu_24_64.tgz \
         && mv linux_ubuntu_24_64  /usr/local/abin \
         && rm -f linux_ubuntu_24_64.tgz" \
   --env PATH=/usr/local/abin:${PATH} \
   --env R_LIBS=/usr/local/share/R-4.3 \
   --run="curl -O         https://afni.nimh.nih.gov/pub/dist/tgz/package_libs/linux_ubuntu_24_R-4.3_libs.tgz \
      && tar -xf         linux_ubuntu_24_R-4.3_libs.tgz \
      && mv              linux_ubuntu_24_R-4.3_libs  ${R_LIBS} \
      && rm -f           linux_ubuntu_24_R-4.3_libs.tgz" \
   --run="@afni_R_package_install ALL" \
   --copy README.md /README.md \
   --copy test.sh /test.sh \
   --copy test.tgz /opt/test.tgz \
   --copy dependencies.R /opt \
   --run="Rscript /opt/dependencies.R" \
   --workdir /opt \
> ${imageName}.${neurodocker_buildExt}
   # --env PATH='$PATH':/opt/freesurfer-7.4.1/tktools:/opt/freesurfer-7.4.1/bin:/opt/freesurfer-7.4.1/fsfast/bin:/opt/freesurfer-7.4.1/mni/bin \
   # --env FREESURFER_HOME="/opt/freesurfer-7.4.1" \
   # --env SUBJECTS_DIR="~/freesurfer-subjects-dir" \
   # --copy license.txt /opt/freesurfer-7.4.1/license.txt \

   # --run="wget --quiet https://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/7.4.1/freesurfer_ubuntu18-7.4.1_amd64.deb \
   #          && apt-get update -qq\
   #          && apt-get install -y ./freesurfer_ubuntu18-7.4.1_amd64.deb \
   #          && ln -s /usr/local/freesurfer/7.4.1-1/ /opt/freesurfer-7.4.1 \
   #          && rm -rf freesurfer_ubuntu18-7.4.1_amd64.deb \
   #          && rm -rf /var/lib/apt/lists/*" \

# This hack is needed for images which set the user to non-root, because neurodocker needs startup scripts that run as root.
# sed -i '/^FROM/a USER root' ${imageName}.${neurodocker_buildExt}

if [ "$1" != "" ]; then
   ./../main_build.sh
fi
