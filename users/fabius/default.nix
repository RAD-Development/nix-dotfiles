{
  config,
  lib,
  pkgs,
  name,
  ...
}:

import ../default.nix {
  inherit
    config
    lib
    pkgs
    name
    ;
  publicKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID8cRp+KuXYIsFL44mWxpmYTc5WrZNsjVbjuQunEtei/ fabius@nixos"
  ];
}
