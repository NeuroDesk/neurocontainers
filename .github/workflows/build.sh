#!/bin/bash

# # Set git user to gh-actions service account
# git config --local user.email "action@github.com"
# git config --local user.name "GitHub Action"

# Build recipe
cd recipes/$APPLICATION
/bin/bash build.sh

# Remove commments
for dockerfile in ./*.Dockerfile; do
  tmp=`tempfile`
  grep -v "^#" $dockerfile > $tmp
  mv $tmp $dockerfile
done

# # Commmit and push recipe
# git add .
# git commit -m "$GITHUB_SHA"
# git remote add github "https://$GITHUB_ACTOR:$GITHUB_TOKEN@github.com/$GITHUB_REPOSITORY.git"
# git pull github ${GITHUB_REF}
# git push github HEAD:${GITHUB_REF}
SHORT_SHA=`git rev-parse --short $GITHUB_SHA`

# Loop through Local Dockerfiles
# Build and Push Dockerfile images
for dockerfile in ./*.Dockerfile; do
  IMAGENAME=$(basename $dockerfile .Dockerfile)
  IMAGENAME=$(echo $IMAGENAME | tr '[A-Z]' '[a-z]')
  IMAGEID=docker.pkg.github.com/$GITHUB_REPOSITORY/$IMAGENAME
  IMAGEID=$(echo $IMAGEID | tr '[A-Z]' '[a-z]')

  # Pull latest image from GH Packages
  docker pull $IMAGEID:latest || echo "$IMAGEID not found. Resuming build..."

  # Build image
  docker build . --file $dockerfile --tag $IMAGEID:$SHORT_SHA --tag  vnmd/$IMAGENAME:$SHORT_SHA --cache-from $IMAGEID

  export BUILDDATE=`date +%Y%m%d`
  # Push to GH Packages
  docker tag $IMAGEID:$SHORT_SHA $IMAGEID:$BUILDDATE
  docker tag $IMAGEID:$SHORT_SHA $IMAGEID:latest
  docker push $IMAGEID:$SHORT_SHA
  docker push $IMAGEID:$BUILDDATE
  docker push $IMAGEID:latest

  # Push to Dockerhub
  docker tag $IMAGEID:$SHORT_SHA vnmd/$IMAGENAME:$SHORT_SHA
  docker tag $IMAGEID:$SHORT_SHA vnmd/$IMAGENAME:$BUILDDATE
  docker tag $IMAGEID:$SHORT_SHA vnmd/$IMAGENAME:latest
  docker push vnmd/$IMAGENAME:$SHORT_SHA
  docker push vnmd/$IMAGENAME:$BUILDDATE
  docker push vnmd/$IMAGENAME:latest

#   # Write Container List (avoid merge conflicts for now?)
#   git pull github ${GITHUB_REF}
#   echo $IMAGENAME >> container_list.txt
#   git add container_list.txt
#   git commit -m "$GITHUB_SHA"
#   git push github HEAD:${GITHUB_REF}
done
