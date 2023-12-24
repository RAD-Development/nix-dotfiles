{ pkgs, lib, config }:
import ../default.nix {
  inherit pkgs lib config;
  userName = "Dennis Wuitz";
  pubKeys = {
    photon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJYHv/LMo8N6iM3zFvOKrF7ZLp3eAG/cOED0yDzrvgkd openpgp:0x74CCE9B8";
  };
}