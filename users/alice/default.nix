{ pkgs, lib, config, name, ... }:
import ../default.nix {
  inherit pkgs lib config name;
  publicKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOGcqhLaKsjwAnb6plDavAhEyQHNvFS9Uh5lMTuwMhGF alice@parthenon-7588"
  ];
}
