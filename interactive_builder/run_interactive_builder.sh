
# This gets called when the user exits the container
function build {
  echo "interactive build complete ... compiling build script ..."
  echo "#!/usr/bin/env bash"  > ./build.sh
  echo "set -e" >> ./build.sh
  history >> history_${timestamp}
  # TODO REMOVE singualarity commands from history
  sed -i '/singularity/d' history_${timestamp}
  cp history_${timestamp} bash_history
  # TODO Ask user how container is called -> insert in final/build.sh + final/README.md
  read -p 'Enter container name: ' container_name && echo "export toolName='$container_name'" >> ./build.sh
# TODO Ask user what version the container is -> insert in final/build.sh 
  read -p 'Enter container version: ' container_version && echo "export toolVersion='$container_version'" >> ./build.sh

# TODO ask for short description of tool -> insert in final/README.sh
  read -p 'Software description: ' software_description && echo $software_description > ./README.md
# TODO ask for an example of running the tool -> insert in final/README.sh
  read -p 'Example of running the tool: ' example && echo $example >> ./README.md
# TODO ask for link to documentation of tool -> insert in final/README.sh
  read -p 'Link to documentation: ' link && echo $link >> ./README.md
# TODO ask for test command of tool -> insert in final/test.sh
  read -p 'Test command of tool: ' test && echo $test > ./test.sh
  python3 extract.py
  echo "cleaning up ..."
  
  export HISTFILE=~/.bash_history
  set -o history
  sudo rm -rf container.sif
  rm bash_history
  echo "done."
}
trap build EXIT

# TODO FIX ordering of commands in build.sh (currently reversed :?)
# TODO Understand both: apt and apt-get and the difference to yum
# Avoid duplicates in history
export HISTCONTROL=ignoredups:erasedups

# After each command, append to the history file and reread it
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

timestamp=$(date +%Y%m%d%H%M%S)

export HISTFILE=history_${timestamp}
touch ${HISTFILE}
set -o history

# TODO ASK USER WHICH BASE IMAGE TO USE and insert in template + insert in build.sh under base-image 
read -p 'Enter base image: ' base_image && echo "--base-image $base_image \\" >> build.sh
# TODO ASK IF DIstribution is apt or yum based: set this in build.sh
read -p 'Enter package manager (apt/yum): ' package_manager && echo "--pkg-manager $package_manager \\" >> build.sh
sudo singularity build --sandbox container.sif template
sudo singularity --silent shell --bind ${HISTFILE}:/root/.bash_history --writable container.sif

# GOTO BUILD TRAP FUNCTION at the start of file!
