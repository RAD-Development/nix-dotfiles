#!/usr/bin/env nix
#! nix shell nixpkgs#bash nixpkgs#findutils nixpkgs#attic-client --command bash

find . -regex ".*\.drv$" -exec attic push cache-nix-dot '/ZFS/ZFS-primary/hydra/{}' \;
