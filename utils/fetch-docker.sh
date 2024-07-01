#!/usr/bin/env nix
#! nix shell nixpkgs#bash nixpkgs#nix-prefetch-docker --command bash

# retrieves the latest image tags

set -x
set -v
set -e

script_path=$(dirname "$(readlink -f $0)")
parent_path=$(dirname "$script_path")

# a list of images to pull
# relpath is the relative path to the parent_path where you want the file written
# format: <image name>,<image tag>,<image architecture>,<os>,<relpath>
images=(
    "nextcloud,apache,amd64,linux,/systems/palatine-hill/docker/nextcloud-image/nextcloud-apache.nix"
)
IFS=","
while read -r name tag arch os relpath; do
    nix-prefetch-docker --image-name "$name" --image-tag "$tag" --arch "$arch" --os "$os" --quiet > "$parent_path/$relpath"
    git --no-pager diff "$parent_path/$relpath"
done<<< "${images[@]}"
