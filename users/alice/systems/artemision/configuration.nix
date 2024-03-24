{ pkgs, ... }:
{
  imports = [
    ../configuration.nix
    ../programs.nix
    ./programs.nix
    ./desktop.nix
  ];

  time.timeZone = "America/New_York";
  console.keyMap = "us";

  # temp workaround for building while in nixos-enter
  services.logrotate.checkConfig = false;

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

  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  services.fwupd.package =
    (import
      (builtins.fetchTarball {
        url = "https://github.com/NixOS/nixpkgs/archive/bb2009ca185d97813e75736c2b8d1d8bb81bde05.tar.gz";
        sha256 = "sha256:003qcrsq5g5lggfrpq31gcvj82lb065xvr7bpfa8ddsw8x4dnysk";
      })
      { inherit (pkgs) system; }
    ).fwupd;

  services.fprintd.enable = false;

  system.stateVersion = "24.05";
}
