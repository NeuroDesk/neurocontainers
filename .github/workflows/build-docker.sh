#!/bin/bash
set -e

echo "[DEBUG] recipes/$APPLICATION"
cd recipes/$APPLICATION

IMAGENAME=$1

if [ -n "$GH_REGISTRY" ]; then
  DOCKER_REGISTRY=$GH_REGISTRY
else
  DOCKER_REGISTRY=$(echo "$GITHUB_REPOSITORY" | awk -F / '{print $1}')
fi
REGISTRY=$(echo ghcr.io/$DOCKER_REGISTRY | tr '[A-Z]' '[a-z]')
IMAGEID="$REGISTRY/$IMAGENAME"
echo "[DEBUG] IMAGENAME: $IMAGENAME"
echo "[DEBUG] REGISTRY: $REGISTRY"
echo "[DEBUG] IMAGEID: $IMAGEID"

echo "[DEBUG] Pulling $IMAGEID"
{
  docker pull $IMAGEID \
    && ROOTFS_CACHE=$(docker inspect --format='{{.RootFS}}' $IMAGEID)
} || echo "$IMAGEID not found. Resuming build..."

echo "[DEBUG] Docker build ..."
docker build . --file ${IMAGENAME}.Dockerfile --tag $IMAGEID:$SHORT_SHA --cache-from $IMAGEID --label "GITHUB_REPOSITORY=$GITHUB_REPOSITORY" --label "GITHUB_SHA=$GITHUB_SHA"

echo "[DEBUG] # Get image RootFS to check for changes ..."
ROOTFS_NEW=$(docker inspect --format='{{.RootFS}}' $IMAGEID:$SHORT_SHA)

# Tag and Push if new image RootFS differs from cached image
if [ "$ROOTFS_NEW" = "$ROOTFS_CACHE" ]; then
    echo "[DEBUG] Skipping push to registry. No changes found"
else
    echo "[DEBUG] Changes found"
fi

# Build singularity container and upload to cache to speed up testing of images:

#This prevents the sometimes stuck apt process from stopping the build
if [ -f "/var/lib/apt/lists/lock" ]; then
  sudo killall apt apt-get
  sudo rm /var/lib/apt/lists/lock
  sudo rm /var/cache/apt/archives/lock
  sudo rm /var/lib/dpkg/lock*
fi

sudo apt-get install -y software-properties-common
sudo add-apt-repository -y ppa:apptainer/ppa
sudo apt-get update
sudo apt-get install -y apptainer 

export IMAGE_HOME="$HOME"

echo "saving docker image locally for singularity to convert:"
docker save $IMAGEID:$SHORT_SHA -o image.tar
singularity build "$IMAGE_HOME/${IMAGENAME}_${BUILDDATE}.simg" docker-archive://image.tar
 
if [ -n "${ORACLE_USER}" ]; then
    echo "[DEBUG] Attempting upload to Oracle ..."
    curl -X PUT -u ${ORACLE_USER} --upload-file $IMAGE_HOME/${IMAGENAME}_${BUILDDATE}.simg $ORACLE_NEURODESK_BUCKET/temporary-builds/

    if curl --output /dev/null --silent --head --fail "https://objectstorage.us-ashburn-1.oraclecloud.com/n/sd63xuke79z3/b/neurodesk/o/temporary-builds/${IMAGENAME}_${BUILDDATE}.simg"; then
        echo "[DEBUG] ${IMAGENAME}_${BUILDDATE}.simg was freshly build and exists now :)"
    else
        echo "[DEBUG] ${IMAGENAME}_${BUILDDATE}.simg does not exist yet. Something is WRONG"
        exit 2
    fi
else
    echo "Upload credentials not set. NOT uploading. This is OK, if it is an external pull request. Otherwise check credentials."
fi


if [ "$GITHUB_REF" == "refs/heads/master" ]; then
    if [ -n "$GH_REGISTRY" ]; then
      echo "[DEBUG] Pushing to GitHub Registry $GH_REGISTRY"
    # Push to GH Packages
      docker tag $IMAGEID:$SHORT_SHA $IMAGEID:$BUILDDATE
      docker tag $IMAGEID:$SHORT_SHA $IMAGEID:latest
      docker push $IMAGEID:$BUILDDATE
      docker push $IMAGEID:latest
    else
      echo "[DEBUG] Skipping push to GitHub Registry. secrets.GH_REGISTRY not found"
    fi
    # Push to Dockerhub
    if [ -n "$DOCKERHUB_ORG" ]; then
      echo "[DEBUG] Pushing to Dockerhub Registry $DOCKERHUB_ORG"
      docker tag $IMAGEID:$SHORT_SHA $DOCKERHUB_ORG/$IMAGENAME:$BUILDDATE
      docker tag $IMAGEID:$SHORT_SHA $DOCKERHUB_ORG/$IMAGENAME:latest
      docker push $DOCKERHUB_ORG/${IMAGENAME}:${BUILDDATE}
      docker push $DOCKERHUB_ORG/$IMAGENAME:latest
    else
      echo "[DEBUG] Skipping push to Dockerhub Registry. secrets.DOCKERHUB_ORG not found"
    fi
else
    echo "[DEBUG] Skipping push to registry. Not on master branch"
fi

