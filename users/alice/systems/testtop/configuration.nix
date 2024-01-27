{ pkgs, ... }:
{
  imports = [
    ../configuration.nix
    ../programs.nix
    ./programs.nix
  ];

  time.timeZone = "America/New_York";
  console.keyMap = "us";
  networking.hostId = "1beb4026";

  boot = {
    zfs.extraPools = [ "Main" ];
    filesystem = "zfs";
    useSystemdBoot = true;
  };

  i18n = {
    defaultLocale = "en_US.utf8";
    supportedLocales = [ "en_US.UTF-8/UTF-8" ];
  };

  boot = {
    default = true;
    kernel.sysctl = {
      "net.ipv6.conf.ens3.accept_ra" = 1;
    };
  };

  system.stateVersion = "23.05";
}
