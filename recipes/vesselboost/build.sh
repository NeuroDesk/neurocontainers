export toolName='vesselboost'
export toolVersion='1.0.1'

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
--base-image pytorch/pytorch:1.13.1-cuda11.6-cudnn8-runtime \
--pkg-manager apt \
--env DEBIAN_FRONTEND=noninteractive \
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
--workdir='/opt/' \
--base-image python:3.12.0-slim \
--pkg-manager apt \
--env DEBIAN_FRONTEND=noninteractive \
--install git cmake g++ libhdf5-dev libxml2-dev libxslt1-dev libboost-all-dev libfftw3-dev libpugixml-dev \
--run='git clone https://github.com/ismrmrd/ismrmrd.git && \
    cd ./ismrmrd' \
--run='cmake .' \
--run='make -j $(nproc)' \
--run='make install' \
--workdir='/opt/'  \
--run='git clone https://github.com/ismrmrd/siemens_to_ismrmrd.git && \
    cd siemens_to_ismrmrd && \
    git checkout v1.2.11' \
--workdir='/opt/siemens_to_ismrmrd/build/' \
--run='cmake /opt/siemens_to_ismrmrd/' \
--run='make -j $(nproc)' \
--run='make install' \
--workdir='/usr/local/lib/' \
--run='tar -czf /opt/ismrmrd_libs.tar.gz libismrmrd*' \
--workdir='/opt/VesselBoost/' \
--env PATH='$PATH':/opt/VesselBoost/ \
--env DEPLOY_BINS=prediction.py:boost.py:test_time_adaptation.py:train.py:python \
--copy README.md /README.md \
> ${toolName}_${toolVersion}.Dockerfile 

if [ "$1" != "" ]; then
   ./../main_build.sh
fi
