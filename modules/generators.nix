{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  imports = [ inputs.nixos-generators.nixosModules.all-formats ];
}
