
## This gets called when the user exits the container
function build {
  echo "interactive build complete ... compiling build script ..."
  echo "#!/usr/bin/env bash"  > ./build.sh
  echo "set -e" >> ./build.sh
  cp $HISTORY_FILE bash_history

  read -p 'Enter tool name (all small caps): ' container_name && echo "export toolName='$container_name'" >> ./build.sh
  read -p 'Enter tool version (no underscores or dashes): ' container_version && echo "export toolVersion='$container_version'" >> ./build.sh
  
  echo " " >> ./build.sh

  echo -en "if [ \"\$1\" != \"\" ]; then\necho \"Entering Debug mode\"\nexport debug=\$1\nfi\n" >> ./build.sh
  
  echo " " >> ./build.sh
  
  echo "source ../main_setup.sh" >> ./build.sh
  echo " " >> ./build.sh
  
  
  echo "neurodocker generate \${neurodocker_buildMode} \\"   >> ./build.sh
  echo "--base-image $base_image \\" >> build.sh
  echo "--pkg-manager $package_manager \\" >> build.sh

  if [ "$package_manager" = "apt" ]; then
      echo "--env DEBIAN_FRONTEND=noninteractive \\" >> build.sh
  fi

  read -p 'Software description: ' software_description 
  read -p 'Example of running the tool: ' example 
  read -p 'Link to documentation: ' link
  echo -en "## $container_name/$container_version ##\n ---- \n\n Description:\n $software_description \n\n Example: \n $example \n\n $link" > ./README.md
  read -p 'Test command of tool: ' test && echo $test > ./test.sh
  
  python3 extract.py
  echo "cleaning up ..."

  rm bash_history
  echo "done."
}
trap build EXIT


## Start here: 

timestamp=$(date +%Y%m%d%H%M%S)

HISTORY_FILE=history_${timestamp}
touch ${HISTORY_FILE}

read -p 'Enter base image (e.g.: centos:7, ubuntu:22.04, fedora:37, pytorch/pytorch:1.13.1-cuda11.6-cudnn8-runtime): ' base_image

if [[ "$base_image" == *"ubuntu"* ]]; then
  package_manager="apt"
  echo "apt based distro detected"
fi

if [[ "$base_image" == *"debian"* ]]; then
  package_manager="apt"
  echo "apt based distro detected"
fi

if [[ "$base_image" == *"centos"* ]]; then
  package_manager="yum"
  echo "yum based distro detected"
fi

if [[ "$base_image" == *"fedora"* ]]; then
  package_manager="yum"
  echo "yum based distro detected"
fi

if [[ -z "$package_manager" ]]; then
    read -p 'Enter package manager (apt/yum): ' package_manager
fi


echo "BootStrap: docker" > template
echo "From: $base_image" >> template

echo "%post -c /bin/bash" >> template
echo "touch /etc/localtime" >> template
echo "touch /usr/bin/nvidia-smi" >> template
echo "touch /usr/bin/nvidia-debugdump" >> template
echo "touch /usr/bin/nvidia-persistenced" >> template
echo "touch /usr/bin/nvidia-cuda-mps-control" >> template
echo "touch /usr/bin/nvidia-cuda-mps-server" >> template
echo "CUSTOM_ENV=/.singularity.d/env/99-zz_custom_env.sh" >> template
echo 'cat >$CUSTOM_ENV <<EOF' >> template
echo "#!/bin/bash" >> template
echo "PS1='\u@neurodesk-builder:\w\$ '" >> template
echo "EOF" >> template
echo '    chmod 755 $CUSTOM_ENV' >> template

if [ "$package_manager" = "apt" ]; then
    echo 'apt update -y' >> template
fi

if [ "$package_manager" = "yum" ]; then
    echo 'yum update -y' >> template
fi


sudo singularity build --fix-perms --sandbox container_${timestamp}.sif template
xhost local:root #This enables root to open display to test graphical applications

if [ "`lspci | grep -i nvidia`" ]
then
        gpu_option=" --nv "
else
        gpu_option=" "
fi

echo "---------------------------------------------------------------"
echo "Now get your tool to work and when done, type exit (or CTRL-D)"
echo "---------------------------------------------------------------"


sudo singularity --silent shell ${gpu_option} --bind ${HISTORY_FILE}:/root/.bash_history,/home/jovyan/Desktop:/root/Desktop --writable container_${timestamp}.sif

# Once user exits container: GOTO BUILD TRAP FUNCTION at the start of file!