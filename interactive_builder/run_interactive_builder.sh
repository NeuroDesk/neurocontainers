
# This gets called when the user exits the container
function build {
  echo "interactive build complete ... compiling build script ..."
# TODO Ask user how container is called -> insert in final/build.sh + final/README.md
# TODO Ask user what version the container is -> insert in final/build.sh 
# TODO REMOVE singualarity commands from history
# TODO ask for short description of tool -> insert in final/README.sh
# TODO ask for an example of running the tool -> insert in final/README.sh
# TODO ask for link to documentation of tool -> insert in final/README.sh
# TODO ask for test of tool -> insert in final/test.sh
# TODO FIX ordering of commands in build.sh (currently reversed :?)
# TODO Understand both: apt and apt-get and the difference to yum
  history >> history_${timestamp}
  cp history_${timestamp} bash_history
  python3 extract.py
  echo "cleaning up ..."
  export HISTFILE=~/.bash_history
  set -o history
  sudo rm -rf container.sif
  rm bash_history
  echo "done."
}
trap build EXIT

# Avoid duplicates in history
export HISTCONTROL=ignoredups:erasedups

# After each command, append to the history file and reread it
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

timestamp=$(date +%Y%m%d%H%M%S)
export HISTFILE=history_${timestamp}
touch ${HISTFILE}
set -o history

# TODO ASK USER WHICH BASE IMAGE TO USE and insert in template + insert in build.sh under base-image 
# TODO ASK IF DIstribution is apt or yum based: set this in build.sh

sudo singularity build --sandbox container.sif template
sudo singularity --silent shell --bind ${HISTFILE}:/root/.bash_history --writable container.sif

# GOTO BUILD TRAP FUNCTION at the start of file!