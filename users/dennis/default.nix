{ pkgs, lib, config }:
import ../default.nix {
  inherit pkgs lib config;
  userName = "Dennis Wuitz";
  pubKeys = {
    photon = "ed25516-AAAAAAA";
  };
}