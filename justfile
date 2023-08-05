
[private]
default:
    @just --list --unsorted --justfile {{justfile()}}

# Clean the docker build cache
clean:
    docker builder prune --all --force

# Build a local image
build image:
    #!/usr/bin/env bash
    echo "Building local image: {{image}}"
    set -eux

    # Determine the local platform and build the given image for it
    local_platform="$(docker version --format '{{{{.Server.Os}}/{{{{.Server.Arch}}')"
    docker buildx build -f "images/{{image}}.dockerfile" \
        --platform "${local_platform}" "images" \
        --tag "{{image}}:latest" --load

# Build, automatically tag the service version, and push a multi-platform image
publish image platforms="linux/arm64,linux/amd64" registry="ghcr.io/dulli": (build image)
    #!/usr/bin/env bash
    echo "Building, tagging and pushing multi-platform image: {{image}} ({{platforms}})"
    set -eux

    # Retrive and parse the image version
    version_raw=$(docker run --rm --entrypoint cat {{image}}:latest /.version)
    version=$(echo "$version_raw" | grep -Eo '[0-9]+\.[0-9]+.?[.0-9A-Za-z-]*' | head -1)
    major=$(echo "$version" | cut -d. -f1)
    minor=$(echo "$version" | cut -d. -f2)
    patch=$(echo "$version" | cut -d. -f3-)

    # Check whether this version was already published
    isnew=$(docker manifest inspect "{{registry}}/{{image}}:${major}.${minor}.${patch}" > /dev/null ; echo $?)
    if [[ $isnew == 0 ]]; then
        echo "{{registry}}/{{image}}:${major}.${minor}.${patch} already exists"
        exit 1
    fi

    # Perform the multiplatform build and publish the tagged image
    docker buildx build -f "images/{{image}}.dockerfile" \
        --platform {{platforms}} "images" \
        --tag "{{registry}}/{{image}}:latest" \
        --tag "{{registry}}/{{image}}:${major}" \
        --tag "{{registry}}/{{image}}:${major}.${minor}" \
        --tag "{{registry}}/{{image}}:${major}.${minor}.${patch}" --push

# (Re-)build all images and publish them
publish-all platforms="linux/arm64,linux/amd64" registry="ghcr.io/dulli":
    #!/usr/bin/env bash
    echo "Publish all images"
    set -u

    # Scan the images folder and handle every file it contains as an image
    for image in `ls -p images | grep -v /`; do
        just --justfile {{justfile()}} \
            publish "$(echo $image | cut -d. -f1)" {{platforms}} {{registry}};
    done
