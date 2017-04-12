#!/bin/bash -e

DOCKER_CACHE_DIR=~/docker-cache

if [[ "$1" == "clean" ]]; then
    echo "Removing ${DOCKER_CACHE_DIR}, are you sure? [yN]"
    read answer
    if [[ "$answer" != "y" ]]; then
        echo "Didn't get y, aborting..."
        exit 1
    else
        rm -rfv ${DOCKER_CACHE_DIR}
        exit 0
    fi
fi

IMAGES=$1
shift

if [[ "$IMAGES" == "" || "$IMAGES" == "--" ]]; then
    >&2 echo "Must specify at least one image name"
    exit 1
fi

while [[ "$1" != "" && "$1" != "--" ]]; do
    IMAGES="$IMAGES $1"
    shift
done

if [[ "$1" == "--" ]]; then shift; fi

mkdir -p ${DOCKER_CACHE_DIR}

for image_directive in $IMAGES; do
    image=$(echo $image_directive | sed 's/::/ /g' | awk '{print $1}')

    if echo $image_directive | grep :: > /dev/null; then
        command=$@
    else
        command="docker run --rm $image echo -"
    fi

    image_filename=$(echo $image | tr '/' '-' | tr '\\' '-').tar

    if [[ -e ${DOCKER_CACHE_DIR}/${image_filename} ]]; then
        docker load -i ${DOCKER_CACHE_DIR}/${image_filename}
    else
        echo "No image archived for ${image_filename}"
    fi

    eval $command

    docker save $image > ${DOCKER_CACHE_DIR}/${image_filename} && echo "Saved $image to ${DOCKER_CACHE_DIR}/${image_filename}"
done
