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

os="$(uname)"

release_tag="$(git describe --tags `git rev-list --tags --max-count=1`)"
echo "Release version: $release_tag"
echo "OS: $os"

git checkout "$release_tag"

mkdir -p release

image_name_prefix="lcl-cli-$release_tag"
binary_name_prefix="lcl-cli-$release_tag-$arch"

function build_for_linux() {
    local platform=$1
    local image_name="$image_name_prefix-$platform"

    echo "arch: $arch"
    echo "platform: $platform"
    echo "image_name: $image_name"
    echo "binary_name: $binary_name_prefix-$platform"

    docker build -t "$image_name" -f "docker/build_$platform.dockerfile" .
    local container_id=$(docker create "$image_name")
    docker cp "$container_id:/lcl" "release/$binary_name_prefix-$platform"
    docker rm -v "$container_id"
    docker image rm -f "$image_name"

    echo "Binary for $platform has been successfully built!"
}

function build_for_macos() {
    echo "arch: $arch"
    echo "platform: macOS"
    echo "binary_name: $binary_name_prefix-macos"

    make build-release
    mv .build/release/lcl release/lcl
    strip release/lcl
    ./release/lcl --help
    mv release/lcl "release/$binary_name_prefix-macos"
}

build_for_linux ubuntu
build_for_linux debian
build_for_macos
