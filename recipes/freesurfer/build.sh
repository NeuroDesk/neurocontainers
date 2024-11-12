#!/usr/bin/env bash
set -e

if [ "$1" != "" ]; then
    echo "Entering Debug mode: -s=singularity; -ds=docker+singularity"
    echo $1
    export debug=$1
fi

export toolName='freesurfer'
export toolVersion=7.4.1

source ../main_setup.sh --reinstall_neurodocker=false

neurodocker generate ${neurodocker_buildMode} \
   --base-image centos:8 \
   --pkg-manager yum \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir -p ${mountPointList}" \
   --run="yum upgrade -y dnf" \
   --run="yum upgrade -y rpm" \
   --install wget \
   --run="wget --quiet https://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/${toolVersion}/freesurfer-CentOS8-${toolVersion}-1.x86_64.rpm \
            && yum --nogpgcheck -y localinstall freesurfer-CentOS8-${toolVersion}-1.x86_64.rpm \
            && ln -s /usr/local/freesurfer/${toolVersion}-1/ /opt/${toolName}-${toolVersion} \
            && rm -rf freesurfer-CentOS8-${toolVersion}-1.x86_64.rpm" \
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
   --run="wget --quiet -O workbench.zip 'https://humanconnectome.org/storage/app/media/workbench/workbench-rh_linux64-v1.5.0.zip' \
      && unzip workbench.zip  \
      && rm -rf workbench.zip" \
      && echo 'Installing AANsegment...' \
      && mkdir -p /opt/AANsegment/bin \
      && mkdir -p /opt/AANsegment/lib \
      && mkdir -p /opt/AANsegment/linux_x86_64 \
      && mkdir -p /opt/AANsegment/mac_osx \
      && mkdir -p /opt/AANsegment/src \
      && cp /Users/VictorVidal/freesurfer/AANsegment/SegmentAAN.sh /opt/AANsegment/bin/SegmentAAN.sh \
      && cp /Users/VictorVidal/freesurfer/AANsegment/AtlasMesh.gz /opt/AANsegment/lib/ \
      && cp /Users/VictorVidal/freesurfer/AANsegment/compressionLookupTable.txt /opt/AANsegment/lib/ \
      && cp /Users/VictorVidal/freesurfer/AANsegment/freeview.lut.txt /opt/AANsegment/lib/ \
      && cp /Users/VictorVidal/freesurfer/AANsegment/targetReg.mgz /opt/AANsegment/lib/ \
      && cp /Users/VictorVidal/freesurfer/AANsegment/targetWorkingres.mgz /opt/AANsegment/lib/ \
      && cp -r /Users/VictorVidal/freesurfer/AANsegment/linux_x86_64/* /opt/AANsegment/linux_x86_64/ \
      && cp -r /Users/VictorVidal/freesurfer/AANsegment/mac_osx/* /opt/AANsegment/mac_osx/ \
      && cp -r /Users/VictorVidal/freesurfer/AANsegment/src/* /opt/AANsegment/src/ \
      && chmod +x /opt/AANsegment/bin/SegmentAAN.sh" \

   --env PATH="/opt/workbench/:/opt/${toolName}-${toolVersion}/bin:/opt/${toolName}-${toolVersion}/fsfast/bin:/opt/${toolName}-${toolVersion}/tktools:/opt/${toolName}-${toolVersion}/bin:/opt/${toolName}-${toolVersion}/fsfast/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/opt/${toolName}-${toolVersion}/mni/bin:/bin" \
   --env FREESURFER="/opt/${toolName}-${toolVersion}" \
   --env DEPLOY_PATH="/opt/${toolName}-${toolVersion}/bin/" \
   --env LD_LIBRARY_PATH="/usr/local/freesurfer/${toolVersion}-1/lib/qt/lib/:/usr/lib64/:/opt/${toolName}-${toolVersion}/MCRv97/runtime/glnxa64:/opt/${toolName}-${toolVersion}/MCRv97/bin/glnxa64:/opt/${toolName}-${toolVersion}/MCRv97/sys/os/glnxa64:/opt/${toolName}-${toolVersion}/MCRv97/sys/opengl/lib/glnxa64:/opt/${toolName}-${toolVersion}/MCRv97/extern/bin/glnxa64" \
   --run="ln -s /usr/local/freesurfer/${toolVersion}-1/* /usr/local/freesurfer/" \
   --copy README.md /README.md \
   --copy test.sh /test.sh \
   --run="bash /test.sh" \
   --copy license.txt /opt/${toolName}-${toolVersion}/license.txt \
   --copy /Applications/freesurfer/bin/SegmentAAN.sh /opt/${toolName}-${toolVersion}/bin/ \
   --run="chmod +x /opt/${toolName}-${toolVersion}/bin/my_script.sh" \
  > ${imageName}.${neurodocker_buildExt}

# Hack to make CENTOS8 work with neurodocker
sed -i '4i RUN sed -i '\''s/mirrorlist/#mirrorlist/g'\'' /etc/yum.repos.d/CentOS-*' ${imageName}.${neurodocker_buildExt}
sed -i '5i RUN sed -i '\''s|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g'\'' /etc/yum.repos.d/CentOS-*' ${imageName}.${neurodocker_buildExt}

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
