{
  pkgs,
  lib,
  config,
  name,
  ...
}:
import ../default.nix {
  inherit
    pkgs
    lib
    config
    name
    ;
  publicKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMtRuAqeERMet9sFh1NEkG+pHLq/JRAAGDtv29flXF59 Richie@tmmworkshop.com Desktop"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHJSlv8ujrMpr8qjpX2V+UBXSP5FGhM1l+/5aGnfb2MV Richie@tmmworkshop.com Laptop"
  ];
}
