#!/bin/bash

# Set git user to gh-actions service account
git config --local user.email "action@github.com"
git config --local user.name "GitHub Action"

# Sync local repo with remote
git remote add github "https://$GITHUB_ACTOR:$GITHUB_TOKEN@github.com/$GITHUB_REPOSITORY.git"
git pull github ${GITHUB_REF} --ff-only

# Build recipe
cd recipes/$APPLICATION
/bin/bash build.sh

# Commmit and push recipe
git add .
git commit -m "$GITHUB_SHA"
git push github HEAD:${GITHUB_REF}

# Loop through Local Dockerfiles
# Build and Push Dockerfile images
for dockerfile in ./*.Dockerfile; do
  IMAGENAME=$(basename $dockerfile .Dockerfile)
  IMAGEID=docker.pkg.github.com/$GITHUB_REPOSITORY/$IMAGENAME
  IMAGEID=$(echo $IMAGEID | tr '[A-Z]' '[a-z]')

  # Pull latest image from GH Packages
  docker pull $IMAGEID:latest || true

  # Build image
  docker build . --file $dockerfile --tag $IMAGEID:latest --tag  vnmd/$IMAGENAME:latest --cache-from $IMAGEID:latest

  # Push to GH Packages
  docker push $IMAGEID:latest
  # Push to Dockerhub
  docker push vnmd/$IMAGENAME:latest
done
