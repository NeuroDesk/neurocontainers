export toolName='vesselboost'
export toolVersion='0.9.2'

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
    git checkout 017212cf6257e903220cf665f84d19b7e498657d' \
--workdir='/opt/VesselBoost/' \
--run='pip install -r requirements.txt ' \
--workdir='/opt/VesselBoost/saved_models' \
--run='osf -p abk4p fetch osfstorage/pretrained_models/manual_ep1000_1029' \
--run='osf -p abk4p fetch osfstorage/pretrained_models/om1_ep1000_1029' \
--run='osf -p abk4p fetch osfstorage/pretrained_models/om2_ep1000_1029' \
--env PATH='$PATH':/opt/VesselBoost/ \
--env DEPLOY_BINS=predictions.py:boost.py:test_time_adaptation.py:train.py \
--copy README.md /README.md \
> ${toolName}_${toolVersion}.Dockerfile 

if [ "$1" != "" ]; then
   ./../main_build.sh
fi
