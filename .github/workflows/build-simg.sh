IMAGENAME=$1

# # install apptainer if no singularity executable is available
# if ! command -v singularity &>/dev/null; then
#   #This prevents the sometimes stuck apt process from stopping the build
#   if [ -f "/var/lib/apt/lists/lock" ]; then
#     sudo rm -f /var/lib/apt/lists/lock
#     sudo rm -f /var/cache/apt/archives/lock
#     sudo rm -f /var/lib/dpkg/lock*
#   fi

#   sudo apt-get install -y software-properties-common
#   sudo add-apt-repository -y ppa:apptainer/ppa
#   sudo apt-get update
#   sudo apt-get install -y apptainer
# fi

# export IMAGE_HOME="/storage/tmp"

# if [ -d "$IMAGE_HOME" ]; then
#   echo "[DEBUG] $IMAGE_HOME exists"
# else
#   echo "[DEBUG] $IMAGE_HOME does not exist. Creating ..."
#   sudo mkdir -p $IMAGE_HOME
#   sudo chmod a+rwx $IMAGE_HOME
# fi

# if [ -f "$IMAGE_HOME/${IMAGENAME}_${BUILDDATE}.simg" ]; then
#   rm -rf $IMAGE_HOME/${IMAGENAME}_${BUILDDATE}.simg
# fi
# echo "[DEBUG] building singularity image from docker image:"
# time singularity build "$IMAGE_HOME/${IMAGENAME}_${BUILDDATE}.simg" docker-daemon://$IMAGEID:$SHORT_SHA
# echo "[DEBUG] done building singularity image from docker image!"