{
  imports = [
    ./hardware.nix
    ../../users/richie/global/syncthing_base.nix
    ../../users/richie/global/zerotier.nix
    ./steam.nix
  ];

  boot = {
    useSystemdBoot = true;
    default = true;
  };

  networking = {
    networkmanager.enable = true;
    hostId = "9b68eb32";
  };

  hardware = {
    pulseaudio.enable = false;
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };

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

    openssh.ports = [ 922 ];

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
          "bob"
          "phone"
          "jeeves"
        ];
        fsWatcherEnabled = true;
      };
      "books" = {
        id = "6uppx-vadmy"; # cspell:disable-line
        path = "/home/richie/books";
        devices = [
          "bob"
          "phone"
          "jeeves"
        ];
        fsWatcherEnabled = true;
      };
      "important" = {
        id = "4ckma-gtshs"; # cspell:disable-line
        path = "/home/richie/important";
        devices = [
          "bob"
          "phone"
          "jeeves"
        ];
        fsWatcherEnabled = true;
      };
      "music" = {
        id = "vprc5-3azqc"; # cspell:disable-line
        path = "/home/richie/music";
        devices = [
          "bob"
          "phone"
          "jeeves"
        ];
        fsWatcherEnabled = true;
      };
      "projects" = {
        id = "vyma6-lqqrz"; # cspell:disable-line
        path = "/home/richie/projects";
        devices = [
          "bob"
          "jeeves"
        ];
        fsWatcherEnabled = true;
      };
    };
  };

  system.autoUpgrade.enable = false;
  system.stateVersion = "23.11";
}
