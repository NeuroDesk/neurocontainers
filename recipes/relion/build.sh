# this template file builds datalad and is then used as a docker base image for layer caching + it contains examples for various things like github install, curl, ...
export toolName='relion'
# toolName or toolVersion CANNOT contain capital letters or dashes or underscores (Docker registry does not accept this!)

export toolVersion='4.0.1' 
# the version number cannot contain a "-" - try to use x.x.x notation always
# toolVersion will automatically be written into README.md - for this to work leave "toolVersion" in the README unaltered.

export COMPUTE_CAPABILITY=$(nvidia-smi --query-gpu=compute_cap --format=csv | sed -ne '2 s/\.// p')
# get the Compute Capability of the GPU to compile relion with the right GPU architecture

# !!!!
# You can test the container build locally by running `bash build.sh -ds`
# !!!!

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi
source ../main_setup.sh
###########################################################################################################################################
# IF POSSIBLE, PLEASE DOCUMENT EACH ARGUMENT PROVIDED TO NEURODOCKER. USE THE `# your comment` NOTATION THAT ALLOWS MID-COMMAND COMMENTS
# NOTE 1: THE QUOTES THAT ENCLOSE EACH COMMENT MUST BE BACKQUOTES (`). OTHER QUOTES WON'T WORK!
# NOTE 2: THE BACKSLASH (\) AT THE END OF EACH LINE MUST FOLLOW THE COMMENT. A BACKSLASH BEFORE THE COMMENT WON'T WORK!
# NOTE 3: COMMENT LINES, I.E. LINES THAT START WITH #, CANNOT BE INCLUDED IN THE MIDDLE OF THE neurodocker generate COMMAND. INSTEAD,
#         USE AN EMPTY LINE AND PUT YOUR COMMENT AT THE END USING THIS FORMAT: `# your comment goes here` \ 
##########################################################################################################################################
neurodocker generate ${neurodocker_buildMode} \
   --base-image ubuntu:22.04                		`# RELION: Using Ubuntu 22.04 because not all required packages were available on neurodebian` \
   --env DEBIAN_FRONTEND=noninteractive                 `# RECOMMENDED TO KEEP AS IS: this disables interactive questions during package installs` \
   --pkg-manager apt                                    `# RECOMMENDED TO KEEP AS IS: desired package manager, has to match the base image (e.g. debian needs apt; centos needs yum)` \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll"   `# RECOMMENDED TO KEEP AS IS: define the ll command to show detailed list including hidden files`  \
   --run="chmod +x /usr/bin/ll"                         `# RECOMMENDED TO KEEP AS IS: make ll command executable`  \
   --run="mkdir -p ${mountPointList}"                   `# MANDATORY: create folders for singularity bind points` \
   --install wget git curl ca-certificates unzip        `# RECOMMENDED: install system packages` \
   --install cmake git build-essential mpi-default-bin mpi-default-dev libfftw3-dev libtiff-dev libpng-dev ghostscript libxft-dev	`# RELION: install relion dependencies` \
   --install libwxgtk3.0-gtk3-dev				`# RELION: install wx-config-3.0 for ctffind-4.1.14` \
   --workdir=/tmp \
   --run="wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-ubuntu2204.pin && `# RELION: steps to install CUDA 11.8 from https://developer.nvidia.com/cuda-11-8-0-download-archive?target_os=Linux&target_arch=x86_64&Distribution=Ubuntu&target_version=22.04&target_type=deb_local` \
          mv cuda-ubuntu2204.pin /etc/apt/preferences.d/cuda-repository-pin-600 && \
          wget https://developer.download.nvidia.com/compute/cuda/11.8.0/local_installers/cuda-repo-ubuntu2204-11-8-local_11.8.0-520.61.05-1_amd64.deb && \
          dpkg -i cuda-repo-ubuntu2204-11-8-local_11.8.0-520.61.05-1_amd64.deb && \
          cp /var/cuda-repo-ubuntu2204-11-8-local/cuda-*-keyring.gpg /usr/share/keyrings/" \
   --install cuda-toolkit-11-8				`# RELION: install CUDA Toolkit 11.8` \
   --run="git clone https://github.com/3dem/relion.git --branch=${toolVersion}"	`# RELION: clone relion git repository` \
   --workdir=/tmp/relion/build				`# RELION: create and move into build directory` \
   --run="cmake -DCUDA_ARCH=${COMPUTE_CAPABILITY} -DCUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda-11.8 -DCMAKE_INSTALL_PREFIX=/opt/${toolName}-${toolVersion} -DFORCE_OWN_FLTK=ON .."	`# RELION: Compile with GPU architecture and CUDA version` \
   --run="make && make install" \
   --env PATH='$PATH':/opt/${toolName}-${toolVersion}/bin `# MANDATORY: add your tool executables to PATH` \
   --env DEPLOY_PATH=/opt/${toolName}-${toolVersion}/bin/ `# MANDATORY: define which directory's binaries should be exposed to module system (alternative: DEPLOY_BINS -> only exposes binaries in the list)` \
   --copy README.md /README.md                          `# MANDATORY: include readme file in container` \
   --copy license.txt /license.txt                          `# MANDATORY: include license file in container` \
   --copy * /neurodesk/                              `# MANDATORY: copy test scripts to /neurodesk folder - build.sh will be included as well, which is a good idea` \
   --run="chmod +x /neurodesk/*.sh"                     `# MANDATORY: allow execution of all shell scripts in /neurodesk inside the container` \
  > ${imageName}.${neurodocker_buildExt}                `# THIS IS THE LAST COMMENT; NOT FOLLOWED BY BACKSLASH!`
  
if [ "$1" != "" ]; then
   ./../main_build.sh
fi
