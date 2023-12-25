{ ... }:
{
  imports = [
    ./banner.nix
  ];

  time.timeZone = "Europe/Berlin";
  console.keyMap = "de";
  i18n.supportedLocales = [ "de_DE.UTF-8/UTF-8" ];

  networking.hostId = "7d76fab7";

  services = {
    nginx = {
      enable = true;
    };

    postgresql = {
      enable = true;
    };

    portunus = {
      #enable = true;
    };

    vaultwarden = {
      enable = true;
    };

    gitea = {
      enable = true;
      #ldap = true;
    };

    nextcloud = {
      #enable = true;
    };
  };


  system.stateVersion = "23.11";
}