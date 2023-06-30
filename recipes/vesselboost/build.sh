export toolName='vesselboost'
export toolVersion='0.6.0'

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
--run='git clone https://github.com/KMarshallX/vessel_code.git' \
--workdir='/opt/vessel_code/' \
--run='pip install -r requirements.txt ' \
--workdir='/opt/vessel_code/saved_models' \
--run='osf -p jg7cr fetch /saved_models/Init_ep1000_lr1e3_tver' \
--copy README.md /README.md \
> ${toolName}_${toolVersion}.Dockerfile 

if [ "$1" != "" ]; then
   ./../main_build.sh
fi
