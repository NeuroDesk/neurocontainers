export toolName='vesselboost'
export toolVersion='1.0.0'

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
--workdir=/opt \
--run='git clone https://github.com/KMarshallX/VesselBoost.git && \
    cd VesselBoost && \
    git checkout master' \
--workdir='/opt/VesselBoost/' \
--run='pip install -r requirements.txt ' \
--workdir='/opt/VesselBoost/saved_models' \
--run='osf -p abk4p fetch osfstorage/pretrained_models/manual_0429' \
--run='osf -p abk4p fetch osfstorage/pretrained_models/omelette1_0429' \
--run='osf -p abk4p fetch osfstorage/pretrained_models/omelette2_0429' \
--env PATH='$PATH':/opt/VesselBoost/ \
--env DEPLOY_BINS=prediction.py:boost.py:test_time_adaptation.py:train.py:python \
--copy README.md /README.md \
> ${toolName}_${toolVersion}.Dockerfile 

if [ "$1" != "" ]; then
   ./../main_build.sh
fi
