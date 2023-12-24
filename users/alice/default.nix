{ pkgs, lib, config }:
import ../default.nix {
  inherit pkgs lib config;
  userName = "AmethystAndroid";
  pubKeys = {
    palatine-hill = "ed25516-AAAAAAA";
  };
}