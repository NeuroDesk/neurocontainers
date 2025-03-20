#!/usr/bin/env bash
set -e

export toolName='prequal'
export toolVersion='1.1.0'

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

yes | neurodocker generate ${neurodocker_buildMode} \
   --base-image ubuntu:20.04 \
   --pkg-manager apt \
   --env DEBIAN_FRONTEND=noninteractive \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir -p ${mountPointList}" \
   --install wget curl git \
   --install software-properties-common \
   --run="add-apt-repository -y ppa:deadsnakes/ppa" \
   --run="add-apt-repository universe -y" \
   --run="apt-get update -qq \
         && DEBIAN_FRONTEND=noninteractive apt-get install -y -q --no-install-recommends \
         build-essential g++ gcc python3.8 python3.8-dev python3.8-venv python3-pip python3.6 python3.6-dev python3.6-venv \
         libeigen3-dev zlib1g-dev qt5-default qtbase5-dev qtchooser qt5-qmake qtbase5-dev-tools \
         libqt5opengl5-dev libqt5svg5-dev libglew-dev libtiff5-dev \
         libpng-dev libfftw3-dev libfftw3-single3 libfftw3-double3 libfftw3-long3 \
         libjpeg-turbo8-dev xvfb python3-distutils libglu1-mesa \
         libgl1-mesa-dev libgl1-mesa-glx libsm6 libice6 libxt6 libxrender1 libxcursor1 libxinerama1 \
         libfreetype6 libxft2 libxrandr2 libgtk2.0-0 libpulse0 libasound2 libcaca0 ghostscript \
         libopenblas-base python-numpy bzip2 dc bc libgomp1 perl psmisc sudo tcsh unzip uuid-dev \
         vim-common mesa-utils libssl-dev libpthread-stubs0-dev libomp-dev openssl librhash-dev \
         libbz2-dev liblzma-dev libarchive-dev libcurl4-openssl-dev libexpat1-dev libjsoncpp-dev \
         libuv1-dev libnghttp2-dev libzstd-dev" \
   --run="apt-get update -qq \
         && DEBIAN_FRONTEND=noninteractive apt-get install -y -q --no-install-recommends \
         build-essential g++ gcc python3.8 python3.8-dev python3.8-venv python3-pip python3.6 python3.6-dev python3.6-venv \
         libeigen3-dev zlib1g-dev qt5-default qtbase5-dev qtchooser qt5-qmake qtbase5-dev-tools \
         libqt5opengl5-dev libqt5svg5-dev libglew-dev libtiff5-dev \
         libpng-dev libfftw3-dev libfftw3-single3 libfftw3-double3 libfftw3-long3 \
         libjpeg-turbo8-dev xvfb python3-distutils libglu1-mesa  \
         libgl1-mesa-dev libgl1-mesa-glx libsm6 libice6 libxt6 libxrender1 libxcursor1 libxinerama1 \
         libfreetype6 libxft2 libxrandr2 libgtk2.0-0 libpulse0 libasound2 libcaca0 ghostscript \
         libopenblas-base python-numpy bzip2 dc bc libgomp1 perl psmisc sudo tcsh unzip uuid-dev \
         vim-common mesa-utils libssl-dev libpthread-stubs0-dev libomp-dev openssl librhash-dev \
         libbz2-dev liblzma-dev libarchive-dev libcurl4-openssl-dev libexpat1-dev libjsoncpp-dev \
         libfreetype6-dev libpng-dev libblas-dev liblapack-dev libatlas-base-dev gfortran \
         python3 python3-numpy python3-dev python3-distutils build-essential libarchive-dev \
         libuv1-dev libnghttp2-dev libzstd-dev libncurses-dev" \
   --workdir /opt \
   --run="ln -s /usr/bin/python3 /usr/bin/python" \
   --run="mkdir -p /APPS /INSTALLERS /INPUTS /SUPPLEMENTAL /OUTPUTS /CODE" \
   --run="chmod 755 /INPUTS /SUPPLEMENTAL /APPS /CODE && chmod 775 /OUTPUTS" \
   --run="git clone https://github.com/MRtrix3/mrtrix3.git /opt/mrtrix3 && \
         cd /opt/mrtrix3 && \
         git checkout 3.0.3 && \
         export NUMBER_OF_PROCESSORS=4 && \
         export CXX=/usr/bin/g++ && \
         export EIGEN_CFLAGS='-isystem /usr/include/eigen3' && \
         export FFTW_CFLAGS='-I/usr/include -I/usr/include/fftw3' && \
         export FFTW_LINKFLAGS='-L/usr/lib/x86_64-linux-gnu -lfftw3 -lfftw3f -lfftw3l' && \
         export QMAKE=/usr/bin/qmake && \
         export MOC=/usr/bin/moc && \
         export RCC=/usr/bin/rcc && \
         export QT_SELECT=5 && \
         ./configure && \
         ./build" \
   --run="cd /INSTALLERS && \
         mkdir -p cmake_install && cd cmake_install && \
         wget https://github.com/Kitware/CMake/releases/download/v3.23.0-rc2/cmake-3.23.0-rc2.tar.gz && \
         tar -xf cmake-3.23.0-rc2.tar.gz && \
         cd cmake-3.23.0-rc2/ && \
         export OPENSSL_ROOT_DIR=/usr && \
         export OPENSSL_CRYPTO_LIBRARY=/usr/lib/x86_64-linux-gnu/libcrypto.so && \
         export OPENSSL_INCLUDE_DIR=/usr/include/openssl && \
         export CMAKE_USE_OPENSSL=ON && \
         export CMAKE_USE_SYSTEM_LIBARCHIVE=OFF && \
         ./bootstrap --parallel=${NUMBER_OF_PROCESSORS} -- \
           -DCMAKE_USE_OPENSSL=ON \
           -DCMAKE_BUILD_TYPE=Release \
           -DBUILD_TESTING=OFF \
           -DCMAKE_USE_SYSTEM_LIBARCHIVE=OFF \
           -DCMAKE_USE_SYSTEM_LIBRARIES=ON \
           -DCMAKE_USE_SYSTEM_LIBRHASH=ON \
           -DOPENSSL_ROOT_DIR=/usr \
           -DOPENSSL_CRYPTO_LIBRARY=/usr/lib/x86_64-linux-gnu/libcrypto.so \
           -DOPENSSL_INCLUDE_DIR=/usr/include/openssl && \
         make -j${NUMBER_OF_PROCESSORS} && make install" \
   --run="cd /INSTALLERS && \
      mkdir -p ants_installer && cd ants_installer && \
      git clone https://github.com/ANTsX/ANTs.git && \
      cd ANTs && \
      git checkout efa80e3f582d78733724c29847b18f3311a66b54 && \
      touch README.txt && \
      mkdir -p ants_build && cd ants_build && \
      cmake /INSTALLERS/ants_installer/ANTs \
      -DCMAKE_INSTALL_PREFIX=/APPS/ants  \
      -DCMAKE_BUILD_TYPE=Release && \
      make -j1 && \
      cd ANTS-build && \
      make install" \
   --run="wget -nv -O /opt/mcr.zip http://ssd.mathworks.com/supportfiles/downloads/R2017a/deployment_files/R2017a/installers/glnxa64/MCR_R2017a_glnxa64_installer.zip && \
         unzip -q /opt/mcr.zip -d /opt/MCR_installer && \
         /opt/MCR_installer/install -mode silent -agreeToLicense yes && \
         rm -r /opt/MCR_installer /opt/mcr.zip" \
   --run="git clone https://github.com/MASILab/PreQual.git /INSTALLERS/PreQual && \
         cd /INSTALLERS/PreQual && \
         git checkout v1.1.0 && \
         mv src/APPS/* /APPS && \
         mv src/CODE/* /CODE && \
         mv src/SUPPLEMENTAL/* /SUPPLEMENTAL" \
   --run="cd /CODE/dtiQA_v7 && \
         python3.8 -m venv venv && \
         . venv/bin/activate && \
         pip3 install --upgrade pip && \
         pip3 install wheel && \
         pip3 install -r /INSTALLERS/PreQual/venv/pip_install_dtiQA.txt && \
         deactivate" \
 --copy environment.yml /APPS/gradtensor/environment.yml \
 --run="cd /APPS/gradtensor && \
         export CONDA_PATH=/APPS/gradtensor/conda && \
         wget https://repo.anaconda.com/miniconda/Miniconda3-py38_23.11.0-2-Linux-x86_64.sh && \
         bash Miniconda3-py38_23.11.0-2-Linux-x86_64.sh -b -p \"\$CONDA_PATH\" && \
         rm Miniconda3-py38_23.11.0-2-Linux-x86_64.sh && \
         export PATH=\"\$CONDA_PATH/bin:\$PATH\" && \
         \"\$CONDA_PATH/bin/conda\" init bash && \
         . \"\$CONDA_PATH/etc/profile.d/conda.sh\" && \
         \"\$CONDA_PATH/bin/conda\" config --add channels conda-forge && \
         \"\$CONDA_PATH/bin/conda\" config --set channel_priority strict && \
         \"\$CONDA_PATH/bin/conda\" create -n gradvenv -y python=3.8 && \
         conda activate gradvenv && \
         conda install -y -c conda-forge dipy=1.5.0 && \
         conda install -y -c conda-forge fpdf imageio pypng freetype-py && \
         git clone https://github.com/scilus/scilpy.git && \
         cd scilpy && \
         git checkout 1.4.0 && \
         pip install --no-deps -e . && \
         conda list > /APPS/gradtensor/conda_packages.txt && \
         conda deactivate" \
   --env PATH="/APPS/gradtensor/conda/bin:$PATH" \
   --run="wget -O /opt/c3d.tar.gz https://downloads.sourceforge.net/project/c3d/c3d/1.0.0/c3d-1.0.0-Linux-x86_64.tar.gz && \
         tar -xf /opt/c3d.tar.gz -C /APPS/ && \
         rm /opt/c3d.tar.gz" \
   --run="cd /APPS/synb0 && \
         python3.6 -m venv pytorch && \
         . pytorch/bin/activate && \
         python3.6 -m pip install --upgrade pip setuptools wheel && \
         sed -i '/pkg-resources==0.0.0/d' /INSTALLERS/PreQual/venv/pip_install_synb0.txt && \
         python3.6 -m pip install -r /INSTALLERS/PreQual/venv/pip_install_synb0.txt && \
         deactivate" \
   --fsl version=6.0.5.1 \
   --freesurfer version=6.0.0 \
 --env PATH="/APPS/mrtrix3/bin:/APPS/c3d-1.0.0-Linux-x86_64/bin:${ANTSPATH}:/APPS/freesurfer/bin:$PATH" \
 --env ANTSPATH="/APPS/ants/bin/" \
 --env CPATH="/usr/local/cuda/include:$CPATH" \
 --env PATH="/usr/local/cuda/bin:$PATH" \
 --env LD_LIBRARY_PATH="/usr/local/cuda/lib64:$LD_LIBRARY_PATH" \
 --env CUDA_HOME="/usr/local/cuda" \
 --env DEPLOY_PATH="/APPS/mrtrix3/bin:/APPS/c3d-1.0.0-Linux-x86_64/bin:${ANTSPATH}" \
 --env DEPLOY_BINS="run_dtiQA.sh,mrinfo,flirt,c3d,antsRegistration" \
 --copy README.md /README.md \
 --copy test.sh /test.sh \
    > ${imageName}.${neurodocker_buildExt}

if [ "$1" != "" ]; then
   ./../main_build.sh
fi