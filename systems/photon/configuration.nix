{ ... }:
{
  imports = [
    ./banner.nix
  ];

  time.timeZone = "Europe/Berlin";
  console.keyMap = "de";
  i18n.supportedLocales = [ "de_DE.UTF-8/UTF-8" ];

  networking.hostId = "7d76fab7";
  boot.initrd.network.ssh.authorizedKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJYHv/LMo8N6iM3zFvOKrF7ZLp3eAG/cOED0yDzrvgkd openpgp:0x74CCE9B8" ];

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