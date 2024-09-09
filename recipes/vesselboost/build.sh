export toolName='vesselboost'
export toolVersion='1.0.1'

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
--base-image pytorch/pytorch:2.4.0-cuda11.8-cudnn9-runtime `# Ubuntu 22.04 base image`\
--pkg-manager apt \
--env DEBIAN_FRONTEND=noninteractive \
--workdir='/opt/code' \
--install build-essential libxslt1.1 libhdf5-103 libboost-program-options1.74.0 libpugixml1v5 vim dos2unix git cmake g++ libhdf5-dev libxml2-dev libxslt1-dev libboost-all-dev libfftw3-dev libpugixml-dev \
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
--workdir='/opt' \
--run='git clone https://github.com/KMarshallX/VesselBoost.git && \
    cd VesselBoost' \
--workdir='/opt/VesselBoost/' \
--run='pip install -r requirements.txt ' \
--workdir='/opt/VesselBoost/saved_models' \
--run='osf -p abk4p fetch osfstorage/pretrained_models/manual_0429' \
--run='osf -p abk4p fetch osfstorage/pretrained_models/omelette1_0429' \
--run='osf -p abk4p fetch osfstorage/pretrained_models/omelette2_0429' \
--workdir='/opt/VesselBoost/' \
--env PATH='$PATH':/opt/VesselBoost/ \
--env DEPLOY_BINS=prediction.py:boost.py:test_time_adaptation.py:train.py:python \
--copy README.md /README.md \
--copy invertcontrast.py /opt/code/python-ismrmrd-server/invertcontrast.py \
> ${toolName}_${toolVersion}.Dockerfile 
# --entrypoint='python3 /opt/code/python-ismrmrd-server/main.py -v -r -H=0.0.0.0 -p=9002 -l=/tmp/python-ismrmrd-server.log -s -S=/tmp/share/saved_data' \






if [ "$1" != "" ]; then
   ./../main_build.sh
fi