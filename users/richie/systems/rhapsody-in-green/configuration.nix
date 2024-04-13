{
  imports = [
    ../programs.nix
    ./hardware.nix
    ../../syncthing_base.nix
  ];
  nixpkgs.config.allowUnfree = true;

  boot = {
    useSystemdBoot = true;
    default = true;
  };

  networking = {
    networkmanager.enable = true;
    hostId = "9b68eb32";
  };

  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  sound.enable = true;

  services = {

    displayManager.sddm.enable = true;

    xserver = {
      enable = true;
      desktopManager.plasma5.enable = true;
      xkb = {
        layout = "us";
        variant = "";
      };
    };

    openssh.enable = true;

    printing.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    syncthing.settings.folders = {
      "notes" = {
        id = "l62ul-lpweo";
        path = "/home/richie/notes";
        devices = [
          "phone"
          "jeeves"
        ];
        fsWatcherEnabled = true;
      };
      "books" = {
        id = "6uppx-vadmy";
        path = "/home/richie/books";
        devices = [
          "phone"
          "jeeves"
        ];
        fsWatcherEnabled = true;
      };
      "important" = {
        id = "4ckma-gtshs";
        path = "/home/richie/important";
        devices = [
          "phone"
          "jeeves"
        ];
        fsWatcherEnabled = true;
      };
      "music" = {
        id = "vprc5-3azqc";
        path = "/home/richie/music";
        devices = [
          "phone"
          "jeeves"
        ];
        "projects" = {
          id = "vyma6-lqqrz";
          path = "/ZFS/Storage/Syncthing/projects";
          devices = [ "jeeves" ];
          fsWatcherEnabled = true;
        };
        fsWatcherEnabled = true;
      };
    };

    zerotierone = {
      enable = true;
      joinNetworks = [ "e4da7455b2ae64ca" ];
    };
  };

  virtualisation = {
    docker = {
      enable = true;
      recommendedDefaults = true;
      logDriver = "local";
      storageDriver = "overlay2";
      daemon."settings" = {
        experimental = true;
        exec-opts = [ "native.cgroupdriver=systemd" ];
        log-opts = {
          max-size = "10m";
          max-file = "5";
        };
      };
    };
  };

  system.stateVersion = "23.11";
}
