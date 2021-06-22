#!/bin/bash

echo "[DEBUG] recipes/$APPLICATION"
cd recipes/$APPLICATION

IMAGENAME=$1
REGISTRY=$(echo ghcr.io/$GITHUB_REPOSITORY | tr '[A-Z]' '[a-z]')
IMAGEID="$REGISTRY/$IMAGENAME"
echo "[DEBUG] IMAGENAME: $IMAGENAME"
echo "[DEBUG] REGISTRY: $REGISTRY"
echo "[DEBUG] IMAGEID: $IMAGEID"

echo "[DEBUG] Docker build ..."
docker build . --file ${IMAGENAME}.Dockerfile --tag $IMAGEID:$SHORT_SHA --label "GITHUB_REPOSITORY=$GITHUB_REPOSITORY" --label "GITHUB_SHA=$GITHUB_SHA"

if [ "$GITHUB_REF" == "refs/heads/master" ]; then
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
fi
