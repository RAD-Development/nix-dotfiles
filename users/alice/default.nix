{ pkgs, lib, config, name, ... }:
import ../default.nix {
  inherit pkgs lib config name;
  pubKeys = [ "ed25516-AAAAAAA" ];
}