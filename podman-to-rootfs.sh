#!/bin/sh
#
if [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ "$1" = "help" ] ||
	[ -z $1 ] || [ -z $2 ]; then

	echo "Usage:"
	echo "	$0 registry/image:tag /path/to/output"
	exit 0
fi

set -o errexit
set -o nounset

IMAGE="$1"
OUTPUT="$2"
DEPENDENCIES="jq tar podman sudo"

for dep in $DEPENDENCIES; do
	if ! command -v "$dep" 2> /dev/null > /dev/null; then
		echo missing dependency jq
		exit 1
	fi
done

mkdir -p "$OUTPUT/image"
mkdir -p "$OUTPUT/rootfs"

echo "#### Pulling $IMAGE..."
#podman pull "$IMAGE"

echo "#### Saving $IMAGE to $OUTPUT/image/ ..."
podman save "$IMAGE" > "$OUTPUT/image/image.tar"

echo "#### Unpacking image..."
tar xf "$OUTPUT/image/image.tar" -C "$OUTPUT/image/"

LAYERS="$(cat "$OUTPUT/image/manifest.json" | jq .[0].Layers | jq 'to_entries[] | "\(.value)"' | tr -d '"')"

for layer in $LAYERS; do
	sudo tar xvf $OUTPUT/image/$layer -C $OUTPUT/rootfs/
done
