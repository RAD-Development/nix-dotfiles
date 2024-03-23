{ pkgs, ... }:
{
  imports = [
    ../configuration.nix
    ../programs.nix
    ./programs.nix
  ];

  time.timeZone = "America/New_York";
  console.keyMap = "us";

  networking = {
    hostId = "58f50a15";
    firewall.enable = true;
  };

  boot = {
    useSystemdBoot = true;
    default = true;
  };

  i18n = {
    defaultLocale = "en_US.utf8";
    supportedLocales = [ "en_US.UTF-8/UTF-8" ];
  };

  virtualisation = {
    docker = {
      enable = true;
      recommendedDefaults = true;
      logDriver = "local";
      storageDriver = "overlay2";
      daemon."settings" = {
        experimental = true;
        data-root = "/var/lib/docker";
        exec-opts = [ "native.cgroupdriver=systemd" ];
        log-opts = {
          max-size = "10m";
          max-file = "5";
        };
      };
    };
  };

  system.stateVersion = "24.05";
}
