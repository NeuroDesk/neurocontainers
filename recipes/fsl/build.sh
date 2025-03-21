#!/usr/bin/env bash
set -e

export toolName='fsl'
export toolVersion='6.0.7.16'
# check for latest version: http://fsl.fmrib.ox.ac.uk/fsldownloads
# check if latest version is in neurodocker https://github.com/ReproNim/neurodocker/blob/master/neurodocker/templates/fsl.yaml

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

yes | neurodocker generate ${neurodocker_buildMode} \
   --base-image ubuntu:20.04 \
   --pkg-manager apt \
   --env DEBIAN_FRONTEND=noninteractive \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir -p ${mountPointList}" \
   --install git ca-certificates ltrace strace wget libxml2 gcc build-essential nvidia-cuda-toolkit \
   --${toolName} version=${toolVersion} \
   --env FSLOUTPUTTYPE=NIFTI_GZ \
   --install locales \
   --run="sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && locale-gen" \
   --env LANG=en_US.UTF-8 \
   --env LANGUAGE=en_US:en \
   --env LC_ALL=en_US.UTF-8 \
   --workdir /opt/ICA-AROMA \
   --run="curl -sSL "https://github.com/rhr-pruim/ICA-AROMA/archive/v0.4.3-beta.tar.gz" | tar -xzC /opt/ICA-AROMA --strip-components 1 \
      && chmod +x /opt/ICA-AROMA/ICA_AROMA.py" \
   --env PATH=/opt/ICA-AROMA/:'$PATH' \
   --run="fslpython -m pip install Cython && rm -rf /root/.cache" \
   --run="fslpython -m pip install oxasl oxasl_ve oxasl_mp && rm -rf /root/.cache" \
   --env DEPLOY_PATH=/opt/${toolName}-${toolVersion}/bin/:/opt/ICA-AROMA/ \
   --env DEPLOY_ENV_FSLDIR=BASEPATH/opt/fsl-${toolVersion} \
   --run="cp /opt/fsl-${toolVersion}/bin/eddy_cuda10.2 /opt/fsl-${toolVersion}/bin/eddy_cuda" \
   --copy eddy /opt/fsl-${toolVersion}/bin/eddy \
   --run="chmod +x /opt/fsl-${toolVersion}/bin/eddy" \
   --run="mkdir -p /opt/fsl_course_data/UnixIntro /opt/fsl_course_data/preCourse /opt/fsl_course_data/registration /opt/fsl_course_data/structural /opt/fsl_course_data/fmri1 /opt/fsl_course_data/fmri2 /opt/fsl_course_data/fmri3 /opt/fsl_course_data/fmri_extras /opt/fsl_course_data/rest /opt/fsl_course_data/fdt /opt/fsl_course_data/mrs /opt/fsl_course_data/asl && \
          wget -c http://fsl.fmrib.ox.ac.uk/fslcourse/downloads/UnixIntro.tar.gz -P /opt/fsl_course_data/UnixIntro && \
          wget -c http://fsl.fmrib.ox.ac.uk/fslcourse/downloads/preCourse.tar.gz -P /opt/fsl_course_data/preCourse && \
          wget -c http://fsl.fmrib.ox.ac.uk/fslcourse/downloads/registration.tar.gz -P /opt/fsl_course_data/registration && \
          wget -c http://fsl.fmrib.ox.ac.uk/fslcourse/downloads/structural.tar.gz -P /opt/fsl_course_data/structural && \
          wget -c http://fsl.fmrib.ox.ac.uk/fslcourse/downloads/fmri1.tar.gz -P /opt/fsl_course_data/fmri1 && \
          wget -c http://fsl.fmrib.ox.ac.uk/fslcourse/downloads/fmri2.tar.gz -P /opt/fsl_course_data/fmri2 && \
          wget -c http://fsl.fmrib.ox.ac.uk/fslcourse/downloads/fmri3.tar.gz -P /opt/fsl_course_data/fmri3 && \
          wget -c http://fsl.fmrib.ox.ac.uk/fslcourse/downloads/fmri_extras.tar.gz -P /opt/fsl_course_data/fmri_extras && \
          wget -c http://fsl.fmrib.ox.ac.uk/fslcourse/downloads/rest.tar.gz -P /opt/fsl_course_data/rest && \
          wget -c http://fsl.fmrib.ox.ac.uk/fslcourse/downloads/fdt.tar.gz -P /opt/fsl_course_data/fdt && \
          wget -c http://fsl.fmrib.ox.ac.uk/fslcourse/downloads/mrs.tar.gz -P /opt/fsl_course_data/mrs && \
          wget -c http://fsl.fmrib.ox.ac.uk/fslcourse/downloads/asl.tar.gz -P /opt/fsl_course_data/asl && \
          for dir in /opt/fsl_course_data/*; do tar -xzf $dir/*.tar.gz -C $dir --strip-components=1; done && \
          rm /opt/fsl_course_data/*/*.tar.gz" \
   --env FSL_COURSE_DATA=/opt/fsl_course_data \
   --env USER=jovyan \
   --copy README.md /README.md \
  > ${imageName}.${neurodocker_buildExt}
   # --run="conda install fsl-truenet" \ #  doens't work yet

# course material links are from here: https://fsl.fmrib.ox.ac.uk/fslcourse/downloads/manifest.json

if [ "$1" != "" ]; then
   ./../main_build.sh
fi

#CUDA SETUP
#FSL 6.0.6.4 only brings eddy_cuda10.2 -> so Ubuntu 20.04 could work because it brings nvidia-cuda-toolkit_10.1.243-3_amd64.deb or 22.04 with nvidia-cuda-toolkit_11.5.1-1ubuntu1_amd64.deb -> needed to patch eddy executable to make this work
