#!/usr/bin/env bash
set -e

#https://afni.nimh.nih.gov/pub/dist/doc/htmldoc/background_install/install_instructs/steps_linux_ubuntu20.html#install-prerequisite-packages
#https://afni.nimh.nih.gov/pub/dist/doc/htmldoc/background_install/install_instructs/steps_linux_Fed_RH.html

export toolName='afni'
export toolVersion=`wget -O- https://afni.nimh.nih.gov/pub/dist/AFNI.version | head -n 1 | cut -d '_' -f 2`
echo $toolVersion #last build with 24.1.02

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

# warning: afni currently needs fedora 35 or older due to a bug in the suma viewer (slider bug documented in tests!)
neurodocker generate ${neurodocker_buildMode} \
   --base-image fedora:35 \
   --pkg-manager yum \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir -p ${mountPointList}" \
   --afni version=latest method=binaries install_r_pkgs='true' install_python3='true' \
   --run="wget --quiet https://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/7.3.2/freesurfer-CentOS8-7.3.2-1.x86_64.rpm \
            && yum --nogpgcheck -y localinstall freesurfer-CentOS8-7.3.2-1.x86_64.rpm \
            && ln -s /usr/local/freesurfer/7.3.2-1/ /opt/freesurfer-7.3.2 \
            && rm -rf freesurfer-CentOS8-7.3.2-1.x86_64.rpm" \
   --env PATH='$PATH':/opt/freesurfer-7.3.2/tktools:/opt/freesurfer-7.3.2/bin:/opt/freesurfer-7.3.2/fsfast/bin:/opt/freesurfer-7.3.2/mni/bin \
   --env FREESURFER_HOME="/opt/freesurfer-7.3.2" \
   --env SUBJECTS_DIR="~/freesurfer-subjects-dir" \
   --copy license.txt /opt/freesurfer-7.3.2/license.txt \
   --env DEPLOY_PATH=/opt/afni-latest/ \
   --run="@afni_R_package_install -afni -shiny -bayes_view" \
   --copy README.md /README.md \
   --copy test.sh /test.sh \
   --copy test.tgz /opt/test.tgz \
  > ${imageName}.${neurodocker_buildExt}
   # --env LC_ALL=C.UTF-8 \


if [ "$1" != "" ]; then
   ./../main_build.sh
fi
