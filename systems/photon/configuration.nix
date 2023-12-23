{ pkgs, lib, config, ... }:
let
in {
  time.timeZone = "Europe/Berlin";
  console.keyMap = "de";

  services = {
    nginx = {
      enable = true;
    };

    postgres = {
      enable = true;
    };

    portunus = {
      enable = true;
    };

    vaultwarden = {
      enable = true;
    };

    gitea = {
      enable = true;
      ldap = true;
    };

    nextcloud = {
      enable = true;
    };
  };


  system.stateVersion = "23.11";
}