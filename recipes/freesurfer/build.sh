#!/usr/bin/env bash
set -e

if [ "$1" != "" ]; then
    echo "Entering Debug mode: -s=singularity; -ds=docker+singularity"
    echo $1
    export debug=$1
fi

export toolName='freesurfer'
export toolVersion=8.0.0
export toolSUBversion=beta

source ../main_setup.sh --reinstall_neurodocker=false

neurodocker generate ${neurodocker_buildMode} \
   --base-image ubuntu:22.04 \
   --pkg-manager apt \
   --env DEBIAN_FRONTEND=noninteractive \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir -p ${mountPointList}" \
   --install wget language-pack-en binutils libx11-dev gettext xterm x11-apps perl make csh tcsh \
            file bc xorg xorg-dev xserver-xorg-video-intel libncurses5 libbsd0 libegl1 libexpat1 \
            libfontconfig1 libfreetype6 libgl1 libglib2.0-0 libglu1-mesa libglvnd0 libglx0 \
            libgomp1 libice6 libicu70 libjpeg62 libmd0 libopengl0 libpcre2-16-0 libpng16-16 \
            libquadmath0 libsm6 libx11-6 libx11-xcb1 libxau6 libxcb-icccm4 libxcb-image0 \
            libxcb-keysyms1 libxcb-randr0 libxcb-render-util0 libxcb-render0 libxcb-shape0 \
            libxcb-shm0 libxcb-sync1 libxcb-util1 libxcb-xfixes0 libxcb-xinerama0 \
            libxcb-xinput0 libxcb-xkb1 libxcb1 libxdmcp6 libxext6 libxft2 libxi6 libxkbcommon-x11-0 \
            libxkbcommon0 libxmu6 libxrender1 libxss1 libxt6 \
            mesa-utils unzip libncurses5 libgomp1 openjdk-8-jdk xvfb xauth \
   --run="wget --quiet https://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/$toolVersion-${toolSUBversion}/freesurfer_ubuntu22-$toolVersion-${toolSUBversion}_amd64.deb \
            && dpkg -i freesurfer_ubuntu22-$toolVersion-${toolSUBversion}_amd64.deb \
            && rm -rf freesurfer_ubuntu22-$toolVersion-${toolSUBversion}_amd64.deb" \
   --matlabmcr version=2019b install_path=/opt/MCR2019b  \
   --workdir /opt/${toolName}-${toolVersion} \
   --run="ln -s /opt/MCR2019b/v97/ /opt/${toolName}-${toolVersion}/MCRv97" \
   --env OS="Linux" \
   --env SUBJECTS_DIR="~/freesurfer-subjects-dir" \
   --env LOCAL_DIR="/opt/${toolName}-${toolVersion}/local" \
   --env FSFAST_HOME="/opt/${toolName}-${toolVersion}/fsfast" \
   --env FMRI_ANALYSIS_DIR="/opt/${toolName}-${toolVersion}/fsfast" \
   --env FUNCTIONALS_DIR="/opt/${toolName}-${toolVersion}/sessions" \
   --env FIX_VERTEX_AREA="" \
   --env FSF_OUTPUT_FORMAT="nii.gz# mni env requirements" \
   --env MINC_BIN_DIR="/opt/${toolName}-${toolVersion}/mni/bin" \
   --env MINC_LIB_DIR="/opt/${toolName}-${toolVersion}/mni/lib" \
   --env MNI_DIR="/opt/${toolName}-${toolVersion}/mni" \
   --env MNI_DATAPATH="/opt/${toolName}-${toolVersion}/mni/data" \
   --env MNI_PERL5LIB="/opt/${toolName}-${toolVersion}/mni/share/perl5" \
   --env PERL5LIB="/opt/${toolName}-${toolVersion}/mni/share/perl5" \
   --env FREESURFER_HOME="/opt/${toolName}-${toolVersion}" \
   --env TERM=xterm \
   --env SHLVL=1 \
   --env FS_OVERRIDE=0 \
   --workdir /opt/workbench/ \
   --run="wget --quiet -O workbench.zip 'https://humanconnectome.org/storage/app/media/workbench/workbench-linux64-v2.0.1.zip' \
      && unzip workbench.zip  \
      && rm -rf workbench.zip" \
   --env PATH='$PATH':/opt/workbench/:/opt/${toolName}-${toolVersion}/bin:/opt/${toolName}-${toolVersion}/fsfast/bin:/opt/${toolName}-${toolVersion}/tktools:/opt/${toolName}-${toolVersion}/bin:/opt/${toolName}-${toolVersion}/fsfast/bin:/opt/${toolName}-${toolVersion}/mni/bin \
   --matlabmcr version=2014b install_path=/opt/MCR2014b  \
   --run="ln -s /opt/MCR2014b/v84/ /opt/${toolName}-${toolVersion}/MCRv84" \
   --env LD_LIBRARY_PATH='$LD_LIBRARY_PATH':/opt/${toolName}-${toolVersion}/MCRv84/runtime/glnxa64:/opt/${toolName}-${toolVersion}/MCRv84/bin/glnxa64:/opt/${toolName}-${toolVersion}/MCRv84/sys/os/glnxa64:/opt/${toolName}-${toolVersion}/MCRv84/sys/opengl/lib/glnxa64:/opt/${toolName}-${toolVersion}/MCRv84/extern/bin/glnxa64 \
   --env FREESURFER="/opt/${toolName}-${toolVersion}" \
   --env DEPLOY_PATH="/opt/${toolName}-${toolVersion}/bin/" \
   --env LD_LIBRARY_PATH='$LD_LIBRARY_PATH':/usr/local/freesurfer/${toolVersion}-1/lib/qt/lib/:/usr/lib64/:/opt/${toolName}-${toolVersion}/MCRv97/runtime/glnxa64:/opt/${toolName}-${toolVersion}/MCRv97/bin/glnxa64:/opt/${toolName}-${toolVersion}/MCRv97/sys/os/glnxa64:/opt/${toolName}-${toolVersion}/MCRv97/sys/opengl/lib/glnxa64:/opt/${toolName}-${toolVersion}/MCRv97/extern/bin/glnxa64 \
   --run="ln -s /usr/local/freesurfer/${toolVersion}-${toolSUBversion}/* /usr/local/freesurfer/" \
   --run="ln -s /usr/local/freesurfer/${toolVersion}-${toolSUBversion}/* /opt/${toolName}-${toolVersion}" \
   --workdir /opt/${toolName}-${toolVersion}/bin/ \
   --run="wget https://raw.githubusercontent.com/freesurfer/freesurfer/refs/heads/dev/AANsegment/linux_x86_64/segmentNuclei && chmod a+rwx segmentNuclei" \
   --copy test.sh /test.sh \
   --copy README.md /README.md \
   --copy license.txt /opt/${toolName}-${toolVersion}/license.txt \
  > ${imageName}.${neurodocker_buildExt}
   # --workdir /opt/AANsegment \
   # --run="wget https://raw.githubusercontent.com/freesurfer/freesurfer/refs/heads/dev/AANsegment/SegmentAAN.sh && chmod a+rwx SegmentAAN.sh" \
   # --run="wget https://raw.githubusercontent.com/freesurfer/freesurfer/refs/heads/dev/AANsegment/AtlasMesh.gz" \
   # --run="wget https://raw.githubusercontent.com/freesurfer/freesurfer/refs/heads/dev/AANsegment/compressionLookupTable.txt" \
   # --run="wget https://raw.githubusercontent.com/freesurfer/freesurfer/refs/heads/dev/AANsegment/targetReg.mgz" \
   # --run="wget https://raw.githubusercontent.com/freesurfer/freesurfer/refs/heads/dev/AANsegment/targetWorkingres.mgz" \
   # --workdir /opt/AANsegment/linux_x86_64 \
   # --run="wget https://raw.githubusercontent.com/freesurfer/freesurfer/refs/heads/dev/AANsegment/linux_x86_64/run_segmentNuclei.sh && chmod a+rwx run_segmentNuclei.sh" \
   # --env PATH='$PATH':/opt/AANsegment:/opt/AANsegment/linux_x86_64 \
   # --workdir /opt/${toolName}-${toolVersion}/average/AAN/atlas/ \
   # --run="wget https://raw.githubusercontent.com/freesurfer/freesurfer/refs/heads/dev/AANsegment/freeview.lut.txt" \

   # :/opt/AANsegment:/opt/AANsegment/linux_x86_64
if [ "$1" != "" ]; then
   ./../main_build.sh
fi

  


# debug segmentSubjectT1_autoEstimateAlveusML:
# dnf install strace -y
# strace segmentSubjectT1_autoEstimateAlveusML
# this failed because java-1.8.0-openjdk wasn't installed!
# solution found here: https://github.com/baxpr/freesurfer720/blob/master/Dockerfile
# for this we needed centos 8 and that's why we can't use the neurodocker version right now

# debug qt and freeview library errors:
# yum update -y
# yum install mlocate
# updatedb
# locate libQt5XcbQpa.so.5