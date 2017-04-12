# Docker CI Cache

When running builds inside of docker on services like CirceCI, the docker environment is ephemeral. This means that, between CI builds, the images build by docker in the last CI job don't persist. This script seeks to alleviate that problem.

```shell
Usage:

    docker-ci-cache.sh <IMAGE1> <IMAGE2> <LOCALLY_BUILT_IMAGE>:: -- <CMD>
    
    <IMAGE1>, <IMAGE2>      - images that can be downloaded automatically by docker
    <LOCALLY_BUILT_IMAGE>:: - An image to cache that is built locally by the CI build. Note the usage
                              of '::' after the image name. This is important
    <CMD>                   - The command that, upon running, will build local images specified by the cache
    
    This script uses 'docker load' to load any tar image archives found in the cache directory, runs either
    'docker run <IMAGE> echo -' or the specified command to download and/or prepare the images for archiving,
    then uses 'docker save' to export a tar image to the cache directory for each specified image.
    The cache directory is ~/docker-cache

Example:

    In the following example, we're caching the postgres 9.3.15 image and the ruby 2.3.0
    image from docker hub, as well as an image based on a Dockerfile in the 'myapp' directory.

    docker-ci-cache.sh postgres:9.3.15 ruby:2.3.0 my-app:latest:: -- 'cd my-app && docker build --tag my-app .'
```
