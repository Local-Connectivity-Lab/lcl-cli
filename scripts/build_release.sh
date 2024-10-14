#!/usr/bin/env bash

set -e

if [[ ! -z "$(git status --porcelain=v1 2>/dev/null)" ]]; then
    echo "There are uncommitted changes in the local tree, please commit or discard them"
    exit 1
fi

raw_arch="$(uname -m)"
case "$raw_arch" in
    "x86_64")
        arch="x86_64"
        ;;

    "aarch64" | "arm64")
        arch="aarch64"
        ;;

    *)
        echo "Error: Unsupported CPU architecture: $raw_arch"
        ;;
esac

release_tag="$(git describe --tags --abbrev=0)"
echo "Release version: $release_tag"

git checkout tags "$release_tag"


function build_with_container() {
    local platform=$1
    local image_name="lcl-cli-$release_tag"
    local binary_name_prefix="lcl-cli-$arch-$release_tag"
    docker build -t "$image_name" -f docker/build_"$platform".dockerfile
    local container_id=$(docker create "$image_name")
    docker cp "$container_id:/lcl" "$image_name-$platform"
    docker rm -v "$container_id"
    docker image rm -f "$image_name"

    echo "Binary for $platform has been successfully built!"
}

build_with_container ubuntu
build_with_container debian

