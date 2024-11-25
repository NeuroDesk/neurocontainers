export toolName='quickshear'
export toolVersion='1.1.0' 

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh --reinstall_neurodocker=false

# freesurfer/synthstrip:1.6 = Ubuntu Jammy 22.04

neurodocker generate ${neurodocker_buildMode} \
   --base-image freesurfer/synthstrip:1.6 \
   --env DEBIAN_FRONTEND=noninteractive \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir -p ${mountPointList}" \
   --workdir /opt \
   --install wget git curl ca-certificates python3 python3-pip \
   --run="pip install quickshear==1.2.0" \
   --install build-essential libxslt1.1 libhdf5-103 libboost-program-options1.74.0 libpugixml1v5 vim dos2unix git cmake g++ libhdf5-dev libxml2-dev libxslt1-dev libboost-all-dev libfftw3-dev libpugixml-dev \
   --workdir='/opt/code' \
   --run='git clone https://github.com/ismrmrd/ismrmrd.git && \
      cd ./ismrmrd && \
      cmake . && \
      make -j $(nproc) && \
      make install' \
   --run='git clone https://github.com/ismrmrd/siemens_to_ismrmrd.git && \
      cd siemens_to_ismrmrd && \
      mkdir build && \
      cd build && \
      cmake .. && \
      make -j $(nproc) && \
      make install' \
   --run='pip3 install h5py ismrmrd matplotlib pydicom pynetdicom nibabel' \
   --run='git clone https://github.com/ismrmrd/ismrmrd-python-tools.git && \
      cd ismrmrd-python-tools && \
      pip3 install --no-cache-dir .' \
   --run='git clone https://github.com/kspaceKelvin/python-ismrmrd-server && \
      find /opt/code/python-ismrmrd-server -name "*.sh" -exec chmod +x {} \; && \
      find /opt/code/python-ismrmrd-server -name "*.sh" | xargs dos2unix' \
   --copy invertcontrast.py /opt/code/python-ismrmrd-server/invertcontrast.py \
   --env DEPLOY_BINS=mri_synthstrip:quickshear \
   --copy README.md /README.md \
   --entrypoint bash \
  > ${imageName}.${neurodocker_buildExt}
  
if [ "$1" != "" ]; then
   ./../main_build.sh
fi
