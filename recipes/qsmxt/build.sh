#!/usr/bin/env bash
set -e

export toolName='qsmxt'
export toolVersion='3.2.1'
# Don't forget to update version change in README.md!!!!!

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

# Version history:
# --qsmxtbase------------------------------------------------------------------------------------------------
# - 1.0.0: Release for preprint including FS7, Minc, FSL
# - 1.1.0: Change to Fastsurfer and replace minc with Ants
# - 1.1.1: update Julia and move packages to depot_Path + changed python version to 3.7
# - 1.1.2: changed python version back to 3.6 with older Miniconda version + fixed versions
# - 1.1.3: Removed FSL, bidscoin, matplotlib, seaborn; added bet2
# - 1.1.3 (fix): Fixed dependency problems occurring with Nipype (see github.com/QSMxT/QSMxT/runs/7553737387)
# --qsmxt----------------------------------------------------------------------------------------------------
# - 1.1.12: Combined qsmxt and qsmxtbase containers
# - 1.1.13: https://github.com/QSMxT/QSMxT/releases/tag/v1.1.13
# - 1.1.13 (container update): Added RomeoApp to Julia for nextQSM testing; removed run_1_fixGEphaseFFTshift.py from DEPLOY_BINS
# - 1.1.13 (container update): Added NeXtQSM
# - 1.2.0: Major update; added QSM.jl; ROMEO unwrapping; Laplacian unwrapping; V-SHARP; RTS QSM; major pipeline refactor
# - 1.3.0: Major update; added premade pipelines, interactive editor, PDF, TV, and fixed networkx version incompatibility
# - 1.3.0 (container update): Fixed FastSurfer to v1.1.1 due to seeming slowness in v2
# - ...
# - 3.2.0: Added fix for scikit-sparse due to Cython bug https://github.com/scikit-sparse/scikit-sparse/releases/tag/v0.4.9

neurodocker generate ${neurodocker_buildMode} \
   --base-image ubuntu:18.04 \
   --pkg-manager apt \
   --env DEBIAN_FRONTEND=noninteractive \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --install bzip2 ca-certificates wget unzip gcc cmake g++ dbus-x11 libgtk2.0-0 git graphviz wget \
      zip libgl1 libglib2.0 libglu1-mesa libsm6 libxrender1 libxt6 libxcomposite1 libfreetype6 \
      libasound2 libfontconfig1 libxkbcommon0 libxcursor1 libxi6 libxrandr2 libxtst6 qt5-default \
      libqt5svg5-dev wget libqt5opengl5-dev libqt5opengl5 libqt5gui5 libqt5core5a libsuitesparse-dev \
      libsqlite3-dev \
   --env PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
   --run="mkdir -p ${mountPointList}" \
   --workdir="/opt/TGV_QSM" \
   --run="wget https://repo.anaconda.com/miniconda/Miniconda2-4.6.14-Linux-x86_64.sh \
       && bash Miniconda2-4.6.14-Linux-x86_64.sh -b -p miniconda2 \
       && miniconda2/bin/conda install -c anaconda cython==0.29.4 \
       && miniconda2/bin/conda install numpy \
       && miniconda2/bin/conda install pyparsing \
       && miniconda2/bin/pip install scipy==0.17.1 nibabel==2.1.0 \
       && miniconda2/bin/conda clean --all \
       && rm Miniconda2-4.6.14-Linux-x86_64.sh" \
   --run="git clone --depth 1 --branch v1.0 https://github.com/QSMxT/TGV_QSM.git" \
   --workdir="/opt/TGV_QSM/TGV_QSM" \
   --copy setup.py "/opt/TGV_QSM/TGV_QSM" \
   --env PYTHONPATH="/opt/TGV_QSM/TGV_QSM/TGV_QSM" \
   --run="/opt/TGV_QSM/miniconda2/bin/python setup.py install \
       && mkdir /opt/TGV_QSM/bin/ \
       && cp /opt/TGV_QSM/miniconda2/bin/tgv_qsm /opt/TGV_QSM/bin/" \
   --env PATH="\${PATH}:/opt/TGV_QSM/bin" \
   --workdir="/opt/bet2" \
   --run="git clone https://github.com/liangfu/bet2.git . \
       && cmake . && make \
       && ln -s /opt/bet2/bin/bet2 /bin/bet" \
   --workdir="/opt" \
   --env SUBJECTS_DIR="/tmp" \
   --ants version=2.3.4 \
   --dcm2niix method=source version=003f0d19f1e57b0129c9dcf3e653f51ca3559028 \
   --miniconda version=4.7.12.1 conda_install='python=3.8' \
   --run="rm -rf /usr/bin/python3.8 \
       && ln -s /opt/miniconda-latest/bin/python /usr/bin/python3.8" \
   --run="git clone --depth 1 --branch v0.4.9 https://github.com/scikit-sparse/scikit-sparse.git \
       && pip install scikit-sparse/" \
   --run="pip install psutil datetime networkx==2.8.8 numpy h5py nibabel nilearn traits nipype scipy scikit-image pydicom pytest seaborn webdavclient3 images-upload-cli qsm-forward==0.5 \
       && pip install cloudstor \
       && pip install niflow-nipype1-workflows \
       && pip install tensorflow packaging" \
   --run="git clone --depth 1 --branch v1.1.1 https://github.com/Deep-MI/FastSurfer.git /opt/FastSurfer \
       && sed -i 's/cu113/cpu/g' /opt/FastSurfer/requirements.txt \
       && pip install -r /opt/FastSurfer/requirements.txt" \
   --env FASTSURFER_HOME="/opt/FastSurfer" \
   --env PATH="\${PATH}:/opt/FastSurfer" \
   --copy test.sh /test.sh \
   --run="git clone --depth 1 --branch v1.0.1 https://github.com/QSMxT/NeXtQSM /opt/nextqsm \
       && python -c \"import cloudstor; cloudstor.cloudstor(url='https://cloudstor.aarnet.edu.au/plus/s/5OehmoRrTr9XlS5', password='').download('', 'nextqsm-weights.tar')\" \
       && tar xf nextqsm-weights.tar -C /opt/nextqsm/checkpoints \
       && rm nextqsm-weights.tar" \
   --env PATH="\${PATH}:/opt/nextqsm/src_tensorflow" \
   --workdir="/opt/bru2" \
   --run="wget https://github.com/neurolabusc/Bru2Nii/releases/download/v1.0.20180303/Bru2_Linux.zip \
       && unzip Bru2_Linux.zip \
       && rm Bru2_Linux.zip" \
   --env PATH="\${PATH}:/opt/bru2" \
   --workdir="/opt" \
   --run="wget https://julialang-s3.julialang.org/bin/linux/x64/1.6/julia-1.6.1-linux-x86_64.tar.gz \
       && tar zxvf julia-1.6.1-linux-x86_64.tar.gz \
       && rm -rf julia-1.6.1-linux-x86_64.tar.gz" \
   --env PATH="\${PATH}:/opt/julia-1.6.1/bin" \
   --workdir="/opt" \
   --copy install_packages.jl "/opt" \
   --env JULIA_DEPOT_PATH="/opt/julia_depot" \
   --run="julia install_packages.jl \
       && chmod -R 755 /opt/julia_depot/packages/RomeoApp" \
   --env JULIA_DEPOT_PATH="~/.julia:/opt/julia_depot" \
   --run="git clone --depth 1 --branch v${toolVersion}  https://github.com/QSMxT/QSMxT" \
   --env PATH="\${PATH}:/opt/QSMxT:/opt/QSMxT/scripts" \
   --env PYTHONPATH="\${PYTHONPATH}:/opt/QSMxT" \
   --workdir="/opt" \
   --run="git clone --depth 1 --branch v0.91 https://github.com/QSMxT/QSMxT-UI" \
   --run="wget https://nodejs.org/dist/v14.17.0/node-v14.17.0-linux-x64.tar.xz \
       && tar xf node-v14.17.0-linux-x64.tar.xz \
       && rm node-v14.17.0-linux-x64.tar.xz" \
   --env PATH="\${PATH}:/opt/node-v14.17.0-linux-x64/bin" \
   --run="cd QSMxT-UI/frontend/ && npm install && CI=false npm run build" \
   --run="cd QSMxT-UI/api/ && npm install --unsafe-perm && npm i -g ts-node" \
   --env PATH="\${PATH}:/opt/QSMxT-UI" \
   --env DEPLOY_PATH="/opt/ants-2.3.4/:/opt/FastSurfer:/opt/QSMxT:/opt/QSMxT/scripts:/opt/QSMxT-UI" \
   --env DEPLOY_BINS="nipypecli:bet:dcm2niix:Bru2:Bru2Nii:tgv_qsm:julia:python3:python:pytest:predict_all.py:qsmxt:qsmxt_version.py:run_0_dicomSort.py:run_1_dicomConvert.py:run_1_niftiConvert.py:run_2_qsm.py:run_3_segment.py:run_4_template.py:run_5_analysis.py"  \
   --env LC_ALL="C.UTF-8" \
   --env LANG="C.UTF-8" \
   --copy README.md /README.md \
  > ${imageName}.${neurodocker_buildExt}

if [ "$1" != "" ]; then
   ./../main_build.sh
fi

# Explanation for Julia hack:
   # --env JULIA_DEPOT_PATH="/opt/julia_depot" \
   # --run="julia install_packages.jl" \
   # --env JULIA_DEPOT_PATH="~/.julia:/opt/julia_depot" \

   # The problem is that Julia packages install by default in the homedirectory
   # in singularity this homedirectory does not exist later on
   # so we have to set the Julia depot path to a path that's available in the image later
   # but: Julia assumes that this path is writable :( because it stores precompiled outputs there
   # solution is to to add a writable path before the unwritable path
   # behaviour: julia writes precompiled stuff to ~/.julia and searches for packages in both, but can't find them in ~/.julia and then searches in /opt/
   # if anyone has a better way of doing this, please let me know: @sbollmann_MRI (Twitter)

