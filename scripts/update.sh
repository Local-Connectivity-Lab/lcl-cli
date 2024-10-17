#!/bin/bash

set -e

# Check if the required tools are installed
if ! command -v curl &> /dev/null || ! command -v jq &> /dev/null; then
	echo "This script requires curl and jq to be installed."
	exit 1
fi

raw_arch=$(uname -m)
echo $raw_arch
case "$raw_arch" in
	"x86_64")
		arch="x86_64"
	;;
	"aarch64" | "arm64")
		arch="aarch64"
	;;
	*)
		echo "Error: Unsupported CPU architecture: $raw_arch"
		exit 1
	;;
esac


raw_os=$(uname)
case "$raw_os" in
	"Darwin")
		os="macos"
	;;
	"Linux")
		if [ -f /etc/os-release ]; then
			. /etc/os-release
			
			# Check if the distribution is Debian or Ubuntu
			if [[ $ID == "debian" ]]; then
				os="denian"
			elif [[ $ID == "ubuntu" ]]; then
				os="ubuntu"
			else
				echo "Unsupported Linux Distribution: $ID"
				exit 1
			fi
		else
			echo "Unable to determine the Linux distribution."
			exit 1
		fi
	;;
	
	*)
		echo "Error: Unsupported OS: $raw_os"
		exit 1
	;;
esac

echo $os


REPO_OWNER="Local-Connectivity-Lab"
PROJECT="lcl-cli"

latest_release=$(curl -s "https://api.github.com/repos/$REPO_OWNER/$PROJECT/releases/latest")

tag_name=$(echo "$latest_release" | jq -r .tag_name)
assets=$(echo "$latest_release" | jq -c '.assets[]')

if [ -z "$assets" ]; then
	echo "No assets found for the latest release: $tag_name"
	exit 1
fi

desired_asset_name="lcl-cli-$tag_name-$arch-$os"

for asset in $assets; do
	asset_name=$(echo "$asset" | jq -r .name)
	if [[ "$desired_asset_name" == "$asset_name" ]]; then
		download_url=$(echo "$asset" | jq -r .browser_download_url)
		curl -L -H "Accept: application/octet-stream" "$download_url" -o "lcl"
		chmod +x lcl
		cp lcl /usr/local/bin
	fi
done
