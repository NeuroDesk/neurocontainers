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
   --base-image afni/afni_make_build:AFNI_$toolVersion `#this is currently a ubuntu bionic 18.04 image` \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir -p ${mountPointList}" \
   --env DEPLOY_PATH=/opt/afni-latest/ \
   --run="wget --quiet https://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/7.4.1/freesurfer_ubuntu18-7.4.1_amd64.deb \
            && apt-get update -qq\
            && apt-get install -y ./freesurfer_ubuntu18-7.4.1_amd64.deb \
            && ln -s /usr/local/freesurfer/7.4.1-1/ /opt/freesurfer-7.4.1 \
            && rm -rf freesurfer_ubuntu18-7.4.1_amd64.deb \
            && rm -rf /var/lib/apt/lists/*" \
   --install software-properties-common \
   --run="sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9"\
   --run="sudo add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/'" \
   --run="sudo add-apt-repository 'deb https://mirror.aarnet.edu.au/pub/ubuntu/archive/ bionic-backports main restricted universe'" \
   --install r-base r-base-dev \
   --run="@afni_R_package_install ALL" \
   --copy README.md /README.md \
   --copy test.sh /test.sh \
   --copy test.tgz /opt/test.tgz \
   --copy dependencies.R /opt \
   --run="Rscript /opt/dependencies.R" \
   --env PATH='$PATH':/opt/freesurfer-7.4.1/tktools:/opt/freesurfer-7.4.1/bin:/opt/freesurfer-7.4.1/fsfast/bin:/opt/freesurfer-7.4.1/mni/bin \
   --env FREESURFER_HOME="/opt/freesurfer-7.4.1" \
   --env SUBJECTS_DIR="~/freesurfer-subjects-dir" \
   --copy license.txt /opt/freesurfer-7.4.1/license.txt \
   --workdir /opt \
> ${imageName}.${neurodocker_buildExt}


# 594.2 The following packages have unmet dependencies:
# 594.2  freesurfer : Depends: language-pack-en but it is not installable
# 594.2               Depends: gettext but it is not installable
# 594.2               Depends: xterm but it is not installable
# 594.2               Depends: csh but it is not installable
# 594.2               Depends: xorg but it is not installable
# 594.2               Depends: xorg-dev but it is not installable
# 594.2               Depends: xserver-xorg-video-intel but it is not installable
# 594.2               Depends: libxcb-icccm4 (>= 0.4.1) but it is not installable
# 594.2               Depends: libxcb-image0 (>= 0.2.1) but it is not installable
# 594.2               Depends: libxcb-keysyms1 (>= 0.4.0) but it is not installable
# 594.2               Depends: libxcb-render-util0 but it is not installable
# 594.2               Depends: libxcb-util1 (>= 0.4.0) but it is not installable
# 594.2               Depends: libxcb-xinerama0 but it is not installable
# 594.2               Depends: libxcb-xinput0 (>= 1.13) but it is not installable
# 594.2               Depends: libxcb-xkb1 but it is not installable
# 594.2               Depends: libxkbcommon-x11-0 (>= 0.5.0) but it is not installable

# This hack is needed for images which set the user to non-root, because neurodocker needs startup scripts that run as root.
sed -i '/^FROM/a USER root' ${imageName}.${neurodocker_buildExt}

if [ "$1" != "" ]; then
   ./../main_build.sh
fi
