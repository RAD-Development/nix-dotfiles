{
  imports = [
    ../../users/richie/global/desktop.nix
    ../../users/richie/global/ssh.nix
    ../../users/richie/global/syncthing_base.nix
    ../../users/richie/global/zerotier.nix
    ./hardware.nix
    ./nvidia.nix
    ./steam.nix
  ];

  boot = {
    useSystemdBoot = true;
    default = true;
  };

  networking = {
    networkmanager.enable = true;
    hostId = "9ab3b18e";
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

    openssh.ports = [ 262 ];

    printing.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    rad-dev.k3s-net.enable = false;

    syncthing.settings.folders = {
      "notes" = {
        id = "l62ul-lpweo"; # cspell:disable-line
        path = "/home/richie/notes";
        devices = [
          "phone"
          "jeeves"
          "rhapsody-in-green"
        ];
        fsWatcherEnabled = true;
      };
      "books" = {
        id = "6uppx-vadmy"; # cspell:disable-line
        path = "/home/richie/books";
        devices = [
          "phone"
          "jeeves"
          "rhapsody-in-green"
        ];
        fsWatcherEnabled = true;
      };
      "important" = {
        id = "4ckma-gtshs"; # cspell:disable-line
        path = "/home/richie/important";
        devices = [
          "phone"
          "jeeves"
          "rhapsody-in-green"
        ];
        fsWatcherEnabled = true;
      };
      "music" = {
        id = "vprc5-3azqc"; # cspell:disable-line
        path = "/home/richie/music";
        devices = [
          "phone"
          "jeeves"
          "rhapsody-in-green"
        ];
        fsWatcherEnabled = true;
      };
      "projects" = {
        id = "vyma6-lqqrz"; # cspell:disable-line
        path = "/home/richie/projects";
        devices = [
          "jeeves"
          "rhapsody-in-green"
        ];
        fsWatcherEnabled = true;
      };
    };
  };

  system.autoUpgrade.enable = false;

  system.stateVersion = "23.11";
}
