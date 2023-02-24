#!/usr/bin/env bash
set -e

export toolName='qsmxt'
export toolVersion='1.3.4'
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
# - 1.1.3 (fix): Fixed dependency problems occuring with Nipype (see github.com/QSMxT/QSMxT/runs/7553737387)
# --qsmxt----------------------------------------------------------------------------------------------------
# - 1.1.12: Combined qsmxt and qsmxtbase containers
# - 1.1.13: https://github.com/QSMxT/QSMxT/releases/tag/v1.1.13
# - 1.1.13 (container update): Added RomeoApp to Julia for nextQSM testing; removed run_1_fixGEphaseFFTshift.py from DEPLOY_BINS
# - 1.1.13 (container update): Added NeXtQSM
# - 1.2.0: Major update; added QSM.jl; ROMEO unwrapping; Laplacian unwrapping; V-SHARP; RTS QSM; major pipeline refactor
# - 1.3.0: Major update; added premade pipelines, interactive editor, PDF, TV, and fixed networkx version incompatibility
# - 1.3.0 (container update): Fixed FastSurfer to v1.1.1 due to seeming slowness in v2

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
   --env PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
   --workdir="/opt/TGVQSM" \
   --run="wget https://repo.anaconda.com/miniconda/Miniconda2-4.6.14-Linux-x86_64.sh" \
   --run="bash Miniconda2-4.6.14-Linux-x86_64.sh -b -p miniconda2" \
   --run="miniconda2/bin/conda install -c anaconda cython==0.29.4" \
   --run="miniconda2/bin/conda install numpy" \
   --run="miniconda2/bin/conda install pyparsing" \
   --run="miniconda2/bin/pip install scipy==0.17.1 nibabel==2.1.0" \
   --run="wget http://www.neuroimaging.at/media/qsm/TGVQSM-plus.zip" \
   --run="unzip TGVQSM-plus.zip && rm TGVQSM-plus.zip" \
   --workdir="/opt/TGVQSM/TGVQSM-master-011045626121baa8bfdd6633929974c732ae35e3" \
   --copy setup.py "/opt/TGVQSM/TGVQSM-master-011045626121baa8bfdd6633929974c732ae35e3" \
   --env PYTHONPATH="/opt/TGVQSM/TGVQSM-master-011045626121baa8bfdd6633929974c732ae35e3/TGV_QSM" \
   --run="/opt/TGVQSM/miniconda2/bin/python setup.py install" \
   --workdir="/opt/TGVQSM/tgvqsm-1.0.0" \
   --run="cp /opt/TGVQSM/miniconda2/bin/tgv_qsm ." \
   --env PATH="\${PATH}:/opt/TGVQSM/tgvqsm-1.0.0" \
   --workdir="/opt/bet2" \
   --run="git clone https://github.com/liangfu/bet2.git ." \
   --run="cmake . && make" \
   --run="ln -s /opt/bet2/bin/bet2 /bin/bet" \
   --env SUBJECTS_DIR="/tmp" \
   --ants version=2.3.4 \
   --dcm2niix method=source version=003f0d19f1e57b0129c9dcf3e653f51ca3559028 \
   --miniconda version=4.7.12.1 conda_install='python=3.8' \
   --run="pip install psutil datetime networkx==2.8.8 numpy h5py nibabel nilearn scikit-sparse traits nipype scipy scikit-image pydicom pytest osfclient seaborn" \
   --run="pip install cloudstor" \
   --run="pip install niflow-nipype1-workflows" \
   --run="git clone --depth 1 --branch v1.1.1 https://github.com/Deep-MI/FastSurfer.git /opt/FastSurfer" \
   --run="sed -i 's/cu113/cpu/g' /opt/FastSurfer/requirements.txt" \
   --run="pip install -r /opt/FastSurfer/requirements.txt" \
   --env FASTSURFER_HOME="/opt/FastSurfer" \
   --env PATH="\${PATH}:/opt/FastSurfer" \
   --copy test.sh /test.sh \
   --run="rm -rf /usr/bin/python3.8 && ln -s /opt/miniconda-latest/bin/python /usr/bin/python3.8" \
   --workdir="/opt" \
   --run="pip install cloudstor tensorflow packaging" \
   --run="git clone --depth 1 --branch v1.0.1 https://github.com/QSMxT/NeXtQSM /opt/nextqsm" \
   --run="python -c \"import cloudstor; cloudstor.cloudstor(url='https://cloudstor.aarnet.edu.au/plus/s/5OehmoRrTr9XlS5', password='').download('', 'nextqsm-weights.tar')\"" \
   --run="tar xf nextqsm-weights.tar -C /opt/nextqsm/checkpoints" \
   --run="rm nextqsm-weights.tar" \
   --env PATH="\${PATH}:/opt/nextqsm/src_tensorflow" \
   --workdir="/opt/bru2" \
   --run="wget https://github.com/neurolabusc/Bru2Nii/releases/download/v1.0.20180303/Bru2_Linux.zip" \
   --run="unzip Bru2_Linux.zip" \
   --env PATH="\${PATH}:/opt/bru2" \
   --workdir="/opt" \
   --run="wget https://julialang-s3.julialang.org/bin/linux/x64/1.6/julia-1.6.1-linux-x86_64.tar.gz" \
   --run="tar zxvf julia-1.6.1-linux-x86_64.tar.gz" \
   --run="rm -rf julia-1.6.1-linux-x86_64.tar.gz" \
   --env PATH="\${PATH}:/opt/julia-1.6.1/bin" \
   --run="mkdir -p ${mountPointList}" \
   --workdir="/opt" \
   --run="git clone --depth 1 --branch v${toolVersion}  https://github.com/QSMxT/QSMxT" \
   --copy install_packages.jl "/opt" \
   --env JULIA_DEPOT_PATH="/opt/julia_depot" \
   --run="julia install_packages.jl" \
   --run="chmod -R 755 /opt/julia_depot/packages/RomeoApp" \
   --env JULIA_DEPOT_PATH="~/.julia:/opt/julia_depot" \
   --run="chmod +x /opt/QSMxT/*.py" \
   --run="chmod +x /opt/QSMxT/scripts/qsmxt_version.py" \
   --env PATH="\${PATH}:/opt/QSMxT:/opt/QSMxT/scripts" \
   --env PYTHONPATH="\${PYTHONPATH}:/opt/QSMxT" \
   --env DEPLOY_PATH="/opt/ants-2.3.4/:/opt/FastSurfer:/opt/QSMxT:/opt/QSMxT/scripts" \
   --env DEPLOY_BINS="nipypecli:bet:dcm2niix:Bru2:Bru2Nii:tgv_qsm:julia:python3:python:pytest:predict_all.py:qsmxt_version.py:run_0_dicomSort.py:run_1_dicomConvert.py:run_1_niftiConvert.py:run_2_qsm.py:run_3_segment.py:run_4_template.py:run_5_analysis.py"  \
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

