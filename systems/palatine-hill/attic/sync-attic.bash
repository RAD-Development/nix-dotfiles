#!/usr/bin/env nix
#! nix shell nixpkgs#bash nixpkgs#findutils nixpkgs#attic-client --command bash

sync_directories=(
    /ZFS/ZFS-primary/hydra
)

for dir in "${sync_directories[@]}"; do
    find "$dir"  -regex ".*\.drv$" -exec attic push cache-nix-dot '{}' \;
done
