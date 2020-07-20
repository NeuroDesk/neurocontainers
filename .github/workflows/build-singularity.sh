
if curl --output /dev/null --silent --head --fail "https://swift.rc.nectar.org.au:8888/v1/AUTH_d6165cc7b52841659ce8644df1884d5e/singularityImages/${IMAGENAMENAME}_${BUILDDATE}.sif"; then
    echo "${IMAGENAME}_${BUILDDATE}.sif exists"
else
#     echo "check space:"
#     df -h

#     echo "cleanup:"
#     docker rmi $(docker image ls -aq)

#     echo "check space:"
#     df -h
    echo "[DEBUG] BUILDDATE: $BUILDDATE"
    echo "[DEBUG] DOCKERHUB_ORG: $DOCKERHUB_ORG"
    REGISTRY=$(echo docker.pkg.github.com/$GITHUB_REPOSITORY | tr '[A-Z]' '[a-z]')
    echo "[DEBUG] REGISTRY: $REGISTRY"
    IMAGENAME=$1
    echo "[DEBUG] IMAGENAME: $IMAGENAME"
    IMAGEID="vnmd/$IMAGENAME"
    echo "[DEBUG] IMAGEID: $IMAGEID"

    echo "[DEBUG] Pulling latest build of singularity ..."
    docker pull $REGISTRY/singularity
    echo "[DEBUG] Build singularity container ..."
    echo "[DEBUG] docker run -v /github/home:/home $REGISTRY/singularity build /home/$IMAGENAME_$BUILDDATE.sif docker://vnmd/$IMAGENAME"
    docker run -v /github/home:/home $REGISTRY/singularity build "/home/$IMAGENAME_$BUILDDATE.sif" docker://vnmd/$IMAGENAME

    echo "[DEBUG] Configure for SWIFT storage"
    pip install python-swiftclient python-keystoneclient
    export OS_AUTH_URL=https://keystone.rc.nectar.org.au:5000/v3/
    export OS_AUTH_TYPE=v3applicationcredential
    export OS_PROJECT_NAME="CAI_Container_Builder"
    export OS_USER_DOMAIN_NAME="Default"
    export OS_REGION_NAME="Melbourne"

    echo "[DEBUG] Attempting upload to swift ..."
    if [ "$GITHUB_REF" == "refs/heads/master" ]; then
        swift upload singularityImages ${IMAGENAME}_${BUILDDATE}.sif --segment-size 1073741824
    fi
fi
