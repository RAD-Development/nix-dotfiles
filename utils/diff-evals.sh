#!/usr/bin/env nix
#! nix shell nixpkgs#bash nixpkgs#gnugrep nixpkgs#nvd --command bash

# diffs each derivation

set -x
set -v
set -e

script_path=$(dirname "$(readlink -f $0)")
parent_path=$(dirname "$script_path")

readarray -t pre_drv < "$parent_path/pre-drv"
readarray -t post_drv < "$parent_path/post-drv"

post_drv_path="$parent_path/post-diff"
# cleanup any files with the same name
rm "$post_drv_path" || true
touch "$post_drv_path"

for i in $(seq 0 $(( "${#pre_drv[@]}" -1 ))); do
    echo "Diffing updates to $(echo "${pre_drv[$i]}" | cut -f 2- -d '-')" >> "$post_drv_path"
    nvd diff "${pre_drv[$i]}" "${post_drv[$i]}" >> "$post_drv_path"
done
