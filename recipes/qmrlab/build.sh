#!/usr/bin/env bash
set -e

export toolName='qMRLab'
export toolVersion='2.4.2'

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

# Use Singlrity/Apptainer to run TinyRange to generate the rootfs.
singularity run docker://ghcr.io/tinyrange/tinyrange:stable build qMRLab.star:qmr_lab_root -o qmr_lab.tar

# MAke sure the automaticcly included template doesn't add to the final layer.
neurodocker generate docker \
    --base-image ubuntu \
    --pkg-manager apt \
    --base-image scratch \
    --add qmr_lab.tar . \
    --run "/init -run-scripts /.pkg/scripts.json" \
    --run "cd /qMRLab-2.4.2;octave --exec \"qMRLabVer\"" \
    --copy qMRLab.sh /usr/bin/qMRLab \
    --entrypoint "/usr/bin/qMRLab" \
    > ${imageName}.${neurodocker_buildExt}

if [ "$1" != "" ]; then
   ./../main_build.sh
fi
