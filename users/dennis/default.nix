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
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJYHv/LMo8N6iM3zFvOKrF7ZLp3eAG/cOED0yDzrvgkd openpgp:0x74CCE9B8"
  ];
}
