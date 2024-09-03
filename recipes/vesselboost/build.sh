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
--workdir='/opt/' \
--install opts="--quiet" git cmake g++ libhdf5-dev libxml2-dev libxslt1-dev libboost-all-dev libfftw3-dev libpugixml-dev \
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
--workdir='/usr/local/lib/' \
--run='tar -czf /opt/ismrmrd_libs.tar.gz libismrmrd*' \
--install git vim \
--workdir='/opt' \
--run='git clone https://github.com/KMarshallX/VesselBoost.git && \
    cd VesselBoost && \
    git checkout e1f628369f181b67fa880c1e6a8edf29885f9717' \
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
> ${toolName}_${toolVersion}.Dockerfile 









if [ "$1" != "" ]; then
   ./../main_build.sh
fi
