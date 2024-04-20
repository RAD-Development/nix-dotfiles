{
  imports = [
    ./hardware.nix
    ./syncthing_base.nix
  ];

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
    autopull.enable = false;

    displayManager.sddm.enable = true;

    xserver = {
      enable = true;
      desktopManager.plasma5.enable = true;
      xkb = {
        layout = "us";
        variant = "";
      };
    };

    printing.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    syncthing.settings.folders = {
      "notes" = {
        id = "l62ul-lpweo"; # cspell:disable-line
        path = "/home/richie/notes";
        devices = [
          "phone"
          "jeeves"
        ];
        fsWatcherEnabled = true;
      };
      "books" = {
        id = "6uppx-vadmy"; # cspell:disable-line
        path = "/home/richie/books";
        devices = [
          "phone"
          "jeeves"
        ];
        fsWatcherEnabled = true;
      };
      "important" = {
        id = "4ckma-gtshs"; # cspell:disable-line
        path = "/home/richie/important";
        devices = [
          "phone"
          "jeeves"
        ];
        fsWatcherEnabled = true;
      };
      "music" = {
        id = "vprc5-3azqc"; # cspell:disable-line
        path = "/home/richie/music";
        devices = [
          "phone"
          "jeeves"
        ];
        "projects" = {
          id = "vyma6-lqqrz"; # cspell:disable-line
          path = "/home/richie/projects";
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

  system.autoUpgrade.enable = false;
  system.stateVersion = "23.11";
}
