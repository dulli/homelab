
# Install CoreOS with a given ignition file from Alpine OS
apk add podman udev
rc-service cgroups start
rc-service udev start

wget -O config.ign $1
podman run --pull=always --privileged --rm -v /dev:/dev -v /run/udev:/run/udev -v .:/data -w /data quay.io/coreos/coreos-installer:release install $2 -i config.ign
rm config.ign