#!/usr/bin/env bash
set -e

# this template file builds datalad and is then used as a docker base image for layer caching + it contains examples for various things like github install, curl, ...
export toolName='mrsiproc'
export toolVersion='0.0.1' #the version number cannot contain a "-" - try to use x.x.x notation always
export matlabVersion='2022a'
export mincVersion='1.9.15'
export lcmodelVersion='6.3'
export hdbetVersion='1.0'
#note the hdbet doesn't really have a version
# Don't forget to update version change in README.md!!!!!
# toolName or toolVersion CANNOT contain capital letters or dashes or underscores (Docker registry does not accept this!)

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
##########################################################################################################################################
neurodocker generate ${neurodocker_buildMode} \
   --base-image mathworks/matlab-deep-learning:r${matlabVersion}                 `# use Matlab deep learning docker container provided by Mathworks` \
   --user root                                          `# change user to root, as the Matlab container runs with Matlab user` \
   --env DEBIAN_FRONTEND=noninteractive                 `# The matlab image uses Ubuntu, so it's Debian` \
   --pkg-manager apt                                    `# desired package manager, has to match the base image (e.g. debian needs apt; centos needs yum)` \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll"   `# define the ll command to show detailed list including hidden files`  \
   --run="chmod +x /usr/bin/ll"                         `# make ll command executable`  \
   --run="mkdir ${mountPointList}"                      `# create folders for singularity bind points` \
   --dcm2niix method=source version=003f0d19f1e57b0129c9dcf3e653f51ca3559028 `# copied from qsmxt` \
   --minc version=${mincVersion}                                 `#install minc and things to make it work ` \
   --miniconda version=latest \
      conda_install='python=3.6' \
   --install wget curl git ca-certificates ltrace strace libxml2 gcc build-essential gzip tar unzip datalad libfftw3-3 software-properties-common `# install apt-get packages` \
   \
   --run="sudo apt remove -y libjpeg62 \
      && wget http://ftp.br.debian.org/debian/pool/main/libj/libjpeg-turbo/libjpeg62-turbo_2.0.6-4_amd64.deb \
      && dpkg -i libjpeg62-turbo_2.0.6-4_amd64.deb \
      && rm libjpeg62-turbo_2.0.6-4_amd64.deb" `# LIBJPEGTURBO_6.2 is required by dcm2mnc` \
   \
   --workdir=/opt/lcmodel-${lcmodelVersion}/ `# install LCModel and things to make it work ` \
   --install curl ca-certificates libxft2 libxss1 libtk8.6 libnet-ifconfig-wrapper-perl vim nano unzip gv unrar `# LCModel dependencies` \
   --run="curl -o /opt/lcm-64.tar http://www.lcmodel.com/pub/LCModel/programs/lcm-64.tar && \
          tar xf /opt/lcm-64.tar && \
          rm -rf /opt/lcm-64.tar" \
   --run="gunzip  -c  lcm-core.tar.gz  |  tar  xf  -" \
   --run="rm -rf lcm-core.tar.gz" \
   --workdir=/opt/lcmodel-${lcmodelVersion}/.lcmodel/basis-sets \
   --run="curl -o /opt/lcmodel-${lcmodelVersion}/.lcmodel/basis-sets/3t.zip http://www.s-provencher.com/pub/LCModel/3t.zip && \
         unzip /opt/lcmodel-${lcmodelVersion}/.lcmodel/basis-sets/3t.zip && \
         rm -rf /opt/lcmodel-${lcmodelVersion}/.lcmodel/basis-sets/3t.zip" \
   --run="curl -o /opt/lcmodel-${lcmodelVersion}/.lcmodel/basis-sets/1.5t.zip http://www.s-provencher.com/pub/LCModel/1.5t.zip && \
         unzip /opt/lcmodel-${lcmodelVersion}/.lcmodel/basis-sets/1.5t.zip && \
         rm -rf /opt/lcmodel-${lcmodelVersion}/.lcmodel/basis-sets/1.5t.zip" \
   --run="curl -o /opt/lcmodel-${lcmodelVersion}/.lcmodel/basis-sets/7t.zip http://www.s-provencher.com/pub/LCModel/7t.zip && \
         unzip /opt/lcmodel-${lcmodelVersion}/.lcmodel/basis-sets/7t.zip && \
         rm -rf /opt/lcmodel-${lcmodelVersion}/.lcmodel/basis-sets/7t.zip" \
   --run="curl -o /opt/lcmodel-${lcmodelVersion}/.lcmodel/basis-sets/9.4t.zip http://www.s-provencher.com/pub/LCModel/9.4t.zip && \
         unzip /opt/lcmodel-${lcmodelVersion}/.lcmodel/basis-sets/9.4t.zip && \
         rm -rf /opt/lcmodel-${lcmodelVersion}/.lcmodel/basis-sets/9.4t.zip" \
   --run="curl -o /opt/lcmodel-${lcmodelVersion}/.lcmodel/basis-sets/basisset_LCModel.zip https://www.ismrm.org/workshops/Spectroscopy16/mrs_fitting_challenge/basisset_LCModel.zip && \
         unzip /opt/lcmodel-${lcmodelVersion}/.lcmodel/basis-sets/basisset_LCModel.zip && \
         rm -rf /opt/lcmodel-${lcmodelVersion}/.lcmodel/basis-sets/basisset_LCModel.zip" \
   --run="curl -o /opt/lcmodel-${lcmodelVersion}/.lcmodel/basis-sets/RawBasis_for_sLASERSiemens_TE_20_BW_4000_NPts_2048.zip http://juchem.bme.columbia.edu/sites/default/files/2021-01/RawBasis_for_sLASERSiemens_TE_20_BW_4000_NPts_2048.zip && \
         unzip /opt/lcmodel-${lcmodelVersion}/.lcmodel/basis-sets/RawBasis_for_sLASERSiemens_TE_20_BW_4000_NPts_2048.zip && \
         rm -rf /opt/lcmodel-${lcmodelVersion}/.lcmodel/basis-sets/RawBasis_for_sLASERSiemens_TE_20_BW_4000_NPts_2048.zip" \
   --run="curl -o /opt/lcmodel-${lcmodelVersion}/.lcmodel/basis-sets/RawBasis_for_sLASERSiemens_TE_20_BW_2500_NPts_1024.zip http://juchem.bme.columbia.edu/sites/default/files/2021-01/RawBasis_for_sLASERSiemens_TE_20_BW_2500_NPts_1024.zip && \
         unzip /opt/lcmodel-${lcmodelVersion}/.lcmodel/basis-sets/RawBasis_for_sLASERSiemens_TE_20_BW_2500_NPts_1024.zip && \
         rm -rf /opt/lcmodel-${lcmodelVersion}/.lcmodel/basis-sets/RawBasis_for_sLASERSiemens_TE_20_BW_2500_NPts_1024.zip" \
   --copy license  /opt/lcmodel-${lcmodelVersion}/.lcmodel/license \
   --workdir=/opt/datasets \
   --run="curl -o /opt/datasets/testdata.rar https://zenodo.org/record/3904443/files/Spectra_hippocampus%28rat%29_TE02.rar?download=1 && \
          unrar x /opt/datasets/testdata.rar  && \
          rm -rf /opt/datasets/testdata.rar" \
   --run="curl -o /opt/lcmodel-${lcmodelVersion}/manual.pdf http://www.lcmodel.com/pub/LCModel/manual/manual.pdf" \
   --copy setup_lcmodel.sh  /opt/lcmodel-${lcmodelVersion}/.lcmodel/bin \
   --workdir /opt/lcmodel-${lcmodelVersion}/.lcmodel/profiles/1/control-defaults \
   --copy controlfiledefault  /opt/lcmodel-${lcmodelVersion}/.lcmodel/profiles/1/control-defaults/controlfiledefault \
   --copy gui-defaults  /opt/lcmodel-${lcmodelVersion}/.lcmodel/profiles/1/gui-defaults \
   --run="chmod a+rwx /opt/lcmodel-${lcmodelVersion} -R" \
   --env DEPLOY_PATH=/opt/lcmodel-${lcmodelVersion}/.lcmodel/bin/:/opt/lcmodel-${lcmodelVersion}/.lcmodel/ \
   --env PATH=/opt/lcmodel-${lcmodelVersion}/.lcmodel/bin/:/opt/lcmodel-${lcmodelVersion}/.lcmodel/:'$PATH' \
   \
   --workdir /opt \
   --run="git clone https://github.com/MIC-DKFZ/HD-BET" \
   --workdir /opt/HD-BET \
   --run="echo 'import os' > /opt/HD-BET/HD_BET/paths.py" \
   --run="echo 'folder_with_parameter_files = \"/opt/HD-BET/hd-bet_params\"' >> /opt/HD-BET/HD_BET/paths.py" \
   --run="mkdir -p /opt/HD-BET/hd-bet_params" \
   --run="curl -o /opt/HD-BET/hd-bet_params/0.model https://zenodo.org/record/2540695/files/0.model?download=1" \
   --run="curl -o /opt/HD-BET/hd-bet_params/1.model https://zenodo.org/record/2540695/files/1.model?download=1" \
   --run="curl -o /opt/HD-BET/hd-bet_params/2.model https://zenodo.org/record/2540695/files/2.model?download=1" \
   --run="curl -o /opt/HD-BET/hd-bet_params/3.model https://zenodo.org/record/2540695/files/3.model?download=1" \
   --run="curl -o /opt/HD-BET/hd-bet_params/4.model https://zenodo.org/record/2540695/files/4.model?download=1" \
   --run="pip install -e ." \
   --env DEPLOY_BINS=hd-bet \
   \
   --env PATH='${PATH}'":/opt/matlab/R${matlabVersion}/bin/"   	 `# set PATH; not required to run matlab, but required for other Matlab tools like mex` \
   --env DEPLOY_BINS=datalad:matlab:mex                 `# specify indiviual binaries (separated by :) on the PATH that should be exposed outside the container for the module system` \
   --env MLM_LICENSE_FILE='~/Downloads'		            `# tell Matlab to look for the license file in Downloads under the home directory. There is the default download folder in Neurodesktop` \
   --run="rm /usr/local/bin/matlab"			               `# rm original matlab symbolic link` \
   --copy matlab /usr/local/bin/matlab                   `# replace original matlab with a script that sets MLM_LICENSE_FILE and then call matlab; license dir is set to ~/Downloads because there is where Firefox download the license to` \
   --run="chmod a+x /usr/local/bin/matlab"     		   `# make matlab executables` \
   --run="mkdir /opt/matlab/R${matlabVersion}/licenses"     		   `# create license directory - this will later be bind-mounted to the homedirectory download folder` \
   --run="chmod a+rwx /opt/matlab/R${matlabVersion}/licenses"     		`# make licenses folder writable - this will be used for an overlay test` \
   --copy README.md /README.md                          `# include readme file in container` \
  > ${imageName}.${neurodocker_buildExt}                `# LAST COMMENT; NOT FOLLOWED BY BACKSLASH!`

## To add in future version
   #--run "export MatlabFunctionsFolder=/opt/mrsiproc/matlab/MatlabFunctions"  `#export dir for matlab scripts` \
   #--run "mkdir -p /opt/mrsiproc/matlab/MatlabFunctions" \
   #--run "chmod a+rwx /opt/mrsiproc/matlab/ -R"  `#setup script dir for matlab functions and assorted scripts` \
   #--run "git clone insert/https/here"
   #--copy ./run_scripts/*mat /opt/mrsiproc/matlab/MatlabFunctions/ \
   #--copy ./run_scripts/*m /opt/mrsiproc/matlab/MatlabFunctions/ \
   #--copy ./run_scripts/*sh /opt/mrsiproc/ \
   #--run "chmod a+rwx /opt/mrsiproc/ -R" \
   #--run "/opt/mrsiproc/startup_matlab.sh" \

if [ "$1" != "" ]; then
   ./../main_build.sh
fi
