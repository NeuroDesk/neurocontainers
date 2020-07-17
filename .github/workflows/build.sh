#!/bin/bash

# # Set git user to gh-actions service account
# git config --local user.email "action@github.com"
# git config --local user.name "GitHub Action"

# Build recipe
cd recipes/$APPLICATION
/bin/bash build.sh

# # Remove commments
# for dockerfile in ./*.Dockerfile; do
#   tmp=$(tempfile)
#   grep -v "^#" $dockerfile > $tmp
#   mv $tmp $dockerfile
# done

# # Commmit and push recipe
# git add .
# git commit -m "$GITHUB_SHA"
# git remote add github "https://$GITHUB_ACTOR:$GITHUB_TOKEN@github.com/$GITHUB_REPOSITORY.git"
# git pull github ${GITHUB_REF}
# git push github HEAD:${GITHUB_REF}
SHORT_SHA=$(git rev-parse --short $GITHUB_SHA)

# Loop through Local Dockerfiles
# Build and Push Dockerfile images
for dockerfile in ./*.Dockerfile; do
  IMAGENAME=$(basename $dockerfile .Dockerfile)
  IMAGENAME=$(echo $IMAGENAME | tr '[A-Z]' '[a-z]')
  IMAGEID=docker.pkg.github.com/$GITHUB_REPOSITORY/$IMAGENAME
  IMAGEID=$(echo $IMAGEID | tr '[A-Z]' '[a-z]')

  # Pull latest image from GH Packages
  {
    docker pull $IMAGEID \
      && ROOTFS_CACHE=$(docker inspect --format='{{.RootFS}}' $IMAGEID)
  } || echo "$IMAGEID not found. Resuming build..."

  # Build image
  docker build . --file $dockerfile --tag $IMAGEID:$SHORT_SHA --cache-from $IMAGEID --label "GITHUB_REPOSITORY=$GITHUB_REPOSITORY" --label "GITHUB_SHA=$GITHUB_SHA"

  # Get image RootFS to check for changes
  ROOTFS_NEW=$(docker inspect --format='{{.RootFS}}' $IMAGEID:$SHORT_SHA)

  # Tag and Push if new image RootFS differs from cached image
  if [ "$ROOTFS_NEW" = "$ROOTFS_CACHE" ]; then
      echo "Skipping push to registry. No changes found in $IMAGEID:$SHORT_SHA"
  else
      echo "Pushing to registry. Changes found in $IMAGEID:$SHORT_SHA"
    export BUILDDATE=`date +%Y%m%d`
    # Push to GH Packages
    docker tag $IMAGEID:$SHORT_SHA $IMAGEID:$BUILDDATE
    docker tag $IMAGEID:$SHORT_SHA $IMAGEID:latest
    docker push $IMAGEID:$BUILDDATE
    docker push $IMAGEID:latest

    # Push to Dockerhub
    if [ -n "$DOCKERHUB_ORG" ]; then
      docker tag $IMAGEID:$SHORT_SHA $DOCKERHUB_ORG/$IMAGENAME:$BUILDDATE
      docker tag $IMAGEID:$SHORT_SHA $DOCKERHUB_ORG/$IMAGENAME:latest
      docker push $DOCKERHUB_ORG/${IMAGENAME}:${BUILDDATE}
      docker push $DOCKERHUB_ORG/$IMAGENAME:latest
    fi

   
  #   # Write Container List (avoid merge conflicts for now?)
  #   git pull github ${GITHUB_REF}
  #   echo $IMAGENAME >> container_list.txt
  #   git add container_list.txt
  #   git commit -m "$GITHUB_SHA"
  #   git push github HEAD:${GITHUB_REF}

 if curl --output /dev/null --silent --head --fail "https://swift.rc.nectar.org.au:8888/v1/AUTH_d6165cc7b52841659ce8644df1884d5e/singularityImages/${IMAGENAME}_${BUILDDATE}.sif"; then
    echo "${IMAGENAME}_${BUILDDATE}.sif exists"
  else
    echo "check space:"
    df -h

    echo "cleanup:"
    docker rmi $(docker image ls -aq)

    echo "check space:"
    df -h

    echo "build singularity container"
    singularity pull docker://$DOCKERHUB_ORG/$IMAGENAME:$BUILDDATE

   # Push to https://cloud.sylabs.io/library/caid
    # This might work one day, but currently this registry just sucks! (11GB of storage and slow)
    # echo "Attempting to push image to singularity hub"
    # singularity push -U ${IMAGENAME}_${BUILDDATE}.sif library://caid/


    pip install python-swiftclient python-keystoneclient
    #configure swift
    export OS_AUTH_URL=https://keystone.rc.nectar.org.au:5000/v3/
    export OS_AUTH_TYPE=v3applicationcredential
    export OS_PROJECT_NAME="CAI_Container_Builder"
    export OS_USER_DOMAIN_NAME="Default"
    export OS_REGION_NAME="Melbourne"

    echo "attempting upload to swift ... "
    swift upload singularityImages ${IMAGENAME}_${BUILDDATE}.sif --segment-size 1073741824
    fi
  fi

done
