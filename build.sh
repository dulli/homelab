IMAGE=${1}
TARGET_PLATFORM=${2:-'linux/arm64,linux/amd64'}
REPO=${REGISTRY:-'ghcr.io/dulli'}

# First, build the image locally...
local_platform=$(docker version --format '{{.Server.Os}}/{{.Server.Arch}}')
echo "Building local image for: ${local_platform}"

docker buildx build -f "images/${IMAGE}.dockerfile" \
    --platform "${local_platform}" "images" \
    --tag "${IMAGE}:latest" --load

# ... to be able to read the version file it contains ...
version=$(docker run --rm --entrypoint cat ${IMAGE}:latest /.version)
major=`echo $version | cut -d. -f1`
minor=`echo $version | cut -d. -f2`
patch=`echo $version | cut -d. -f3`
echo "Service Version: ${major}.${minor}.${patch}"

# ... and build/tag the image for all platforms.
docker buildx build -f "images/${IMAGE}.dockerfile" \
    --platform ${TARGET_PLATFORM} "images" \
    --tag "${REPO}/${IMAGE}:latest" \
    --tag "${REPO}/${IMAGE}:${major}" \
    --tag "${REPO}/${IMAGE}:${major}.${minor}" \
    --tag "${REPO}/${IMAGE}:${major}.${minor}.${patch}" \
    --push

