#!/usr/bin/env bash
set -e

export toolName='spinalcordtoolbox'
export toolVersion='5.5'
# Don't forget to update version change in README.md!!!!!

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi
source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base-image ubuntu:16.04 \
   --pkg-manager apt \
   --install="gcc ca-certificates libmpich-dev python3-pyqt5 git curl bzip2 libglib2.0-0" \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir ${mountPointList}" \
   --run="curl -fsSL --retry 5 https://github.com/spinalcordtoolbox/spinalcordtoolbox/archive/refs/tags/${toolVersion}.tar.gz | tar -xz -C /opt/ " \
   --workdir="/opt/${toolName}-${toolVersion}" \
   --run="chmod a+rwx /opt/${toolName}-${toolVersion}/ -R" \
   --user=${toolName} \
   --run="yes | ./install_sct -i" \
   --env DEPLOY_PATH=/opt/${toolName}-${toolVersion}/bin/ \
   --env SCT_DIR=/opt/${toolName}-${toolVersion}/ \
   --env PATH=/opt/${toolName}-${toolVersion}/bin/:/bin/:$PATH \
   --run="sct_deepseg -install-task seg_exvivo_gm-wm_t2" \
   --run="sct_deepseg -install-task seg_tumor-edema-cavity_t1-t2" \
   --run="sct_deepseg -install-task seg_tumor_t2" \
   --run="sct_deepseg -install-task seg_mice_gm" \
   --run="sct_deepseg -install-task seg_mice_sc" \
   --run="sct_deepseg -install-task seg_sc_t2star" \
   --run="bash /opt/spinalcordtoolbox-${toolVersion}/batch_processing.sh" \
   --copy README.md /README.md \
  > ${toolName}_${toolVersion}.Dockerfile


if [ "$1" != "" ]; then
   ./../main_build.sh
fi
