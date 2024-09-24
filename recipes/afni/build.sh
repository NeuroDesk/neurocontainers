#!/usr/bin/env bash
set -e

#https://afni.nimh.nih.gov/pub/dist/doc/htmldoc/background_install/install_instructs/steps_linux_ubuntu20.html#install-prerequisite-packages
#https://afni.nimh.nih.gov/pub/dist/doc/htmldoc/background_install/install_instructs/steps_linux_Fed_RH.html
#From https://github.com/afni/afni/blob/14a9d3b7bb36dd7d6c8315205418ae94a41e15bc/src/RomanImperator.h#L31
#/* AFNI_VERSION_LABEL, defined in file AFNI_version.h, is a string of the form
#     AFNI_ab.c.de
#   where ab = year minus 2000 (e.g., 18 for 2018)
#         c  = quarter within the year = 0, 1, 2, or 3
#         de = minor number of version
#   Macro AFNI_VERSION_RomanImperator (far below) uses ab and c to choose the
#   cognomen (catch name) from the version; this macro is used in afni.c
#   (cf. function show_AFNI_version() ) when option '-ver' is given to print
#   out the AFNI version; e.g.,
#     Oct 20 2020 (Version AFNI_20.3.01 'Vespasian')
## so - pretty safe to assume that the version is 24.3.01 etc. 
export toolName='afni'
export toolVersion='24.2.06'
echo $toolVersion #

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
