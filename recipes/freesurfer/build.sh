#!/usr/bin/env bash
set -e

if [ "$1" != "" ]; then
    echo "Entering Debug mode: -s=singularity; -ds=docker+singularity"
    echo $1
    export debug=$1
fi

export toolName='freesurfer'
export toolVersion=8.0.0

source ../main_setup.sh --reinstall_neurodocker=false

neurodocker generate ${neurodocker_buildMode} \
   --base-image ubuntu:22.04 \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir -p ${mountPointList}" \
   --install wget \
   --run="wget --quiet https://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/$toolVersion-beta/freesurfer_ubuntu22-$toolVersion-beta_amd64.deb \
            && deb install freesurfer_ubuntu22-$toolVersion-beta_amd64.deb \
            && ln -s /usr/local/freesurfer/${toolVersion}-1/ /opt/${toolName}-${toolVersion} \
            && rm -rf freesurfer_ubuntu22-$toolVersion-beta_amd64.deb" \
   --install mesa-dri-drivers which unzip ncurses-compat-libs libgomp java-1.8.0-openjdk xorg-x11-server-Xvfb xorg-x11-xauth \
   --matlabmcr version=2019b install_path=/opt/MCR2019b  \
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
   --workdir /opt/AANsegment \
   --run="wget https://raw.githubusercontent.com/freesurfer/freesurfer/refs/heads/dev/AANsegment/SegmentAAN.sh && chmod a+rwx SegmentAAN.sh" \
   --run="wget https://raw.githubusercontent.com/freesurfer/freesurfer/refs/heads/dev/AANsegment/AtlasMesh.gz" \
   --run="wget https://raw.githubusercontent.com/freesurfer/freesurfer/refs/heads/dev/AANsegment/compressionLookupTable.txt" \
   --run="wget https://raw.githubusercontent.com/freesurfer/freesurfer/refs/heads/dev/AANsegment/targetReg.mgz" \
   --run="wget https://raw.githubusercontent.com/freesurfer/freesurfer/refs/heads/dev/AANsegment/targetWorkingres.mgz" \
   --workdir /opt/AANsegment/linux_x86_64 \
   --run="wget https://raw.githubusercontent.com/freesurfer/freesurfer/refs/heads/dev/AANsegment/linux_x86_64/segmentNuclei && chmod a+rwx segmentNuclei" \
   --run="wget https://raw.githubusercontent.com/freesurfer/freesurfer/refs/heads/dev/AANsegment/linux_x86_64/run_segmentNuclei.sh && chmod a+rwx run_segmentNuclei.sh" \
   --workdir /opt/${toolName}-${toolVersion}/average/AAN/atlas/ \
   --run="wget https://raw.githubusercontent.com/freesurfer/freesurfer/refs/heads/dev/AANsegment/freeview.lut.txt" \
   --env PATH='$PATH':/opt/AANsegment:/opt/AANsegment/linux_x86_64 \
   --env FREESURFER="/opt/${toolName}-${toolVersion}" \
   --env DEPLOY_PATH="/opt/${toolName}-${toolVersion}/bin/:/opt/AANsegment:/opt/AANsegment/linux_x86_64" \
   --env LD_LIBRARY_PATH='$LD_LIBRARY_PATH':/usr/local/freesurfer/${toolVersion}-1/lib/qt/lib/:/usr/lib64/:/opt/${toolName}-${toolVersion}/MCRv97/runtime/glnxa64:/opt/${toolName}-${toolVersion}/MCRv97/bin/glnxa64:/opt/${toolName}-${toolVersion}/MCRv97/sys/os/glnxa64:/opt/${toolName}-${toolVersion}/MCRv97/sys/opengl/lib/glnxa64:/opt/${toolName}-${toolVersion}/MCRv97/extern/bin/glnxa64 \
   --run="ln -s /usr/local/freesurfer/${toolVersion}-1/* /usr/local/freesurfer/" \
   --copy test.sh /test.sh \
   --copy README.md /README.md \
   --copy license.txt /opt/${toolName}-${toolVersion}/license.txt \
  > ${imageName}.${neurodocker_buildExt}

# Hack to make CENTOS8 work with neurodocker
sed -i '4i RUN sed -i '\''s/mirrorlist/#mirrorlist/g'\'' /etc/yum.repos.d/CentOS-*' ${imageName}.${neurodocker_buildExt}
sed -i '5i RUN sed -i '\''s|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g'\'' /etc/yum.repos.d/CentOS-*' ${imageName}.${neurodocker_buildExt}
sed -i '6i RUN yum install -y ca-certificates' ${imageName}.${neurodocker_buildExt}

sed -i '/ENV LANG="en_US.UTF-8" \\/,+2d' ${imageName}.${neurodocker_buildExt}
sed -i '/localedef \\/d' ${imageName}.${neurodocker_buildExt}
sed -i '/&& localedef -i en_US -f UTF-8 en_US.UTF-8 \\/d' ${imageName}.${neurodocker_buildExt}

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