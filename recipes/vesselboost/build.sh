export toolName='vesselboost'
export toolVersion='0.9.1'

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
--run='git clone https://github.com/KMarshallX/vessel_code.git && \
    cd vessel_code && \
    git checkout ac1c1c885224a0890f732fedc4fcd0d375946d96' \
--workdir='/opt/vessel_code/' \
--run='pip install -r requirements.txt ' \
--workdir='/opt/vessel_code/saved_models' \
--run='osf -p abk4p fetch osfstorage/pretrained_models/manual_ep1000_1029' \
--run='osf -p abk4p fetch osfstorage/pretrained_models/om1_ep1000_1029' \
--run='osf -p abk4p fetch osfstorage/pretrained_models/om2_ep1000_1029' \
--copy README.md /README.md \
> ${toolName}_${toolVersion}.Dockerfile 

if [ "$1" != "" ]; then
   ./../main_build.sh
fi
