export toolName='glmsingle'
export toolVersion='1.2'
 
if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
    --base-image ubuntu:20.04 \
    --pkg-manager apt \
    --env DEBIAN_FRONTEND=noninteractive \
    --install python3.8 python3-pip libpython3.8-dev git \
    --run 'python3.8 -m pip install git+https://github.com/cvnlab/GLMsingle.git@1.2' \
    --run 'python3.8 -m pip install ipykernel jupyterlab' \
    --copy README.md /README.md \
    > ${toolName}_${toolVersion}.Dockerfile

if [ "$1" != "" ]; then
    ./../main_build.sh
fi
