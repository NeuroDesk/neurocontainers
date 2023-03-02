
# This gets called when the user exits the container
function build {
  echo "interactive build complete ... compiling build script ..."
  echo "#!/usr/bin/env bash"  > ./build.sh
  echo "set -e" >> ./build.sh
  cp $HISTORY_FILE bash_history

  # TODO Ask user how container is called -> insert in final/build.sh + final/README.md
  read -p 'Enter container name: ' container_name && echo "export toolName='$container_name'" >> ./build.sh
# TODO Ask user what version the container is -> insert in final/build.sh 
  read -p 'Enter container version: ' container_version && echo "export toolVersion='$container_version'" >> ./build.sh

  echo -en "if [ \"\$1\" != \"\" ]; then\necho \"Entering Debug mode\"\nexport debug=\$1\nfi\n" >> ./build.sh
  echo "source ../main_setup.sh" >> ./build.sh
  echo "neurodocker generate \${neurodocker_buildMode} \\"   >> ./build.sh
  echo "--base-image $base_image \\" >> build.sh
  echo "--pkg-manager $package_manager \\" >> build.sh

# TODO ask for short description of tool -> insert in final/README.sh
  read -p 'Software description: ' software_description 
# TODO ask for an example of running the tool -> insert in final/README.sh
  read -p 'Example of running the tool: ' example 
# TODO ask for link to documentation of tool -> insert in final/README.sh
  read -p 'Link to documentation: ' link
  echo -en "## $container_name/$container_version ##\n ---- \n\n Description:\n $software_description \n\n Example: \n $example \n\n $link" > ./README.md
# TODO ask for test command of tool -> insert in final/test.sh
  read -p 'Test command of tool: ' test && echo $test > ./test.sh
  python3 extract.py
  echo "cleaning up ..."

  sudo rm -rf container.sif
  rm bash_history
  echo "done."
}
trap build EXIT

timestamp=$(date +%Y%m%d%H%M%S)

HISTORY_FILE=history_${timestamp}
touch ${HISTORY_FILE}

# TODO ASK USER WHICH BASE IMAGE TO USE and insert in template + insert in build.sh under base-image 
read -p 'Enter base image: ' base_image
# TODO ASK IF DIstribution is apt or yum based: set this in build.sh
read -p 'Enter package manager (apt/yum): ' package_manager
sudo singularity build --sandbox container.sif template
sudo singularity --silent shell --bind ${HISTORY_FILE}:/root/.bash_history --writable container.sif

# GOTO BUILD TRAP FUNCTION at the start of file!