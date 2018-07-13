#!/usr/bin/env bash

imageName='fsl_5p0p11'
buildDate=`date +%Y%m%d`

#install neurodocker
#pip3 install --no-cache-dir https://github.com/kaczmarj/neurodocker/tarball/master --user

#upgrade neurodocker
#pip install --no-cache-dir https://github.com/kaczmarj/neurodocker/tarball/master --upgrade

neurodocker generate singularity \
   --base debian:wheezy \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir /90days /30days /QRISdata /RDS /data /short /proc_temp /TMPDIR /nvme /local /gpfs1" \
   --install libdbus-glib-1-2 libjpeg62 libgtk2.0-0  libpng12-0 \
   --fsl version=5.0.11 \
   -e FSLOUTPUTTYPE=NIFTI_GZ \
   --user=neuro \
   > Singularity.${imageName}

sudo singularity build ${imageName}_${buildDate}.simg Singularity.${imageName}

singularity shell --bind $PWD:/data ${imageName}_${buildDate}.simg
