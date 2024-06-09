{ lib, machineConfig, ... }:
{
  imports = [
    ./home/programs.nix
    ./home/sshconfig.nix
    ./home/cli
  ] ++ lib.optionals (!machineConfig.server) [ ./home/gui ];

  nixpkgs.config.allowUnfree = true;

  home = {
    username = "richie";
    homeDirectory = "/home/richie";
  };

  home.stateVersion = "23.11";
}
