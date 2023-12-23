{ pkgs, lib, config, ... }:
let
in {

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
}