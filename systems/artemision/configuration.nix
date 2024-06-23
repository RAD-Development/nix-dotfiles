{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./programs.nix
    ./desktop.nix
    ./wifi.nix
    ./zerotier.nix
    ./fonts.nix
    ./polkit.nix
    ./audio.nix
    ./fingerprint.nix
    ./steam.nix
    ./graphics.nix
  ];

  time.timeZone = "America/New_York";

  # temp workaround for building while in nixos-enter
  #services.logrotate.checkConfig = false;

  networking = {
    hostId = "58f50a15";
    firewall.enable = true;
    useNetworkd = true;
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_zen;
    useSystemdBoot = true;
    default = true;
  };

  i18n = {
    defaultLocale = "en_US.utf8";
    supportedLocales = [ "en_US.UTF-8/UTF-8" ];
  };

  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  services = {

    fwupd = {
      enable = true;
      package =
        (import (builtins.fetchTarball {
          url = "https://github.com/NixOS/nixpkgs/archive/bb2009ca185d97813e75736c2b8d1d8bb81bde05.tar.gz";
          sha256 = "sha256:003qcrsq5g5lggfrpq31gcvj82lb065xvr7bpfa8ddsw8x4dnysk";
        }) { inherit (pkgs) system; }).fwupd;
    };

    fprintd.enable = true;
    openssh.enable = lib.mkForce false;

    spotifyd = {
      enable = true;
      settings = {
        global = {
          username = "snowinginwonderland@gmail.com";
          password_cmd = "cat ${config.sops.secrets."apps/spotify".path}";
          use_mpris = false;
        };
      };
      #systemd.services.spotifyd.serviceConfig = systemd.services.spotifyd.
    };
  };

  system.autoUpgrade.enable = false;
  system.stateVersion = "24.05";

  sops = {
    defaultSopsFile = ./secrets.yaml;
    secrets = {
      "apps/spotify" = {
        group = "audio";
        restartUnits = [ "spotifyd.service" ];
        mode = "0440";
      };
    };
  };
}
