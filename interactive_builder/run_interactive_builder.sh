
## This gets called when the user exits the container
function build {
  echo "interactive build complete ... compiling build script ..."
  echo "#!/usr/bin/env bash"  > ./build.sh
  echo "set -e" >> ./build.sh
  cp $HISTORY_FILE bash_history

  read -p 'Enter container name: ' container_name && echo "export toolName='$container_name'" >> ./build.sh
  read -p 'Enter container version: ' container_version && echo "export toolVersion='$container_version'" >> ./build.sh

  echo -en "if [ \"\$1\" != \"\" ]; then\necho \"Entering Debug mode\"\nexport debug=\$1\nfi\n" >> ./build.sh
  echo "source ../main_setup.sh" >> ./build.sh
  echo "neurodocker generate \${neurodocker_buildMode} \\"   >> ./build.sh
  echo "--base-image $base_image \\" >> build.sh
  echo "--pkg-manager $package_manager \\" >> build.sh

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

read -p 'Enter base image (e.g.: centos:7, ubuntu:22.04, fedora:37): ' base_image
export base_image=$base_image
read -p 'Enter package manager (apt/yum): ' package_manager
sudo singularity build --sandbox container_${timestamp}.sif template
sudo singularity --silent shell --bind ${HISTORY_FILE}:/root/.bash_history --writable container.sif

# Once user exits container: GOTO BUILD TRAP FUNCTION at the start of file!