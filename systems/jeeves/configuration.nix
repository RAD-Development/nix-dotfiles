{ pkgs, ... }:
{

  networking = {
    hostId = "1beb3027";
    firewall.enable = false;
  };

  boot = {
    zfs.extraPools = [
      "Media"
      "Storage"
      "Torenting"
    ];
    filesystem = "zfs";
    useSystemdBoot = true;
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

    podman = {
      enable = true;
      recommendedDefaults = true;
    };
  };

  environment = {
    systemPackages = with pkgs; [ docker-compose ];
    etc = {
      # Creates /etc/lynis/custom.prf
      "lynis/custom.prf" = {
        text = ''
          skip-test=BANN-7126
          skip-test=BANN-7130
          skip-test=DEB-0520
          skip-test=DEB-0810
          skip-test=FIRE-4513
          skip-test=HRDN-7222
          skip-test=KRNL-5820
          skip-test=LOGG-2190
          skip-test=LYNIS
          skip-test=TOOL-5002
        '';
        mode = "0440";
      };
    };
  };

  services = {
    nfs.server.enable = true;

    openssh.ports = [ 629 ];

    plex = {
      enable = true;
      dataDir = "/ZFS/Media/Plex/";
    };

    smartd.enable = true;

    sysstat.enable = true;

    syncthing = {
      enable = true;
      user = "richie";
      overrideDevices = true;
      overrideFolders = true;
      dataDir = "/home/richie/Syncthing";
      configDir = "/home/richie/.config/syncthing";
      guiAddress = "192.168.90.40:8384";
      settings = {
        devices = {
          "Phone" = {
            id = "LTGPLAE-M4ZDJTM-TZ3DJGY-SLLAVWF-CQDVEVS-RGCS75T-GAPZYK3-KUM6LA5";
          };
          "rhapsody-in-green" = {
            id = "INKUNKN-KILXGL5-2TQ5JTH-ORJOLOM-WYD2PYO-YRDLQIX-3AKZFWT-ZN7OJAE";
          };
        };
        folders = {
          "notes" = {
            id = "l62ul-lpweo";
            path = "/ZFS/Media/Notes";
            devices = [
              "Phone"
              "rhapsody-in-green"
            ];
            fsWatcherEnabled = true;
          };
          "books" = {
            id = "6uppx-vadmy";
            path = "/ZFS/Storage/Syncthing/books";
            devices = [
              "Phone"
              "jeeves"
            ];
            fsWatcherEnabled = true;
          };
          "important" = {
            id = "4ckma-gtshs";
            path = "/ZFS/Storage/Syncthing/important";
            devices = [
              "Phone"
              "jeeves"
            ];
            fsWatcherEnabled = true;
          };
        };
      };
    };

    usbguard = {
      enable = false;
      rules = ''
        allow id 1532:0241
      '';
    };

    zfs = {
      trim.enable = true;
      autoScrub.enable = true;
    };

    zerotierone = {
      enable = true;
      joinNetworks = [
        "e4da7455b2ae64ca"
        "52b337794f23c1d4"
      ];
    };
  };

  system.stateVersion = "23.11";
}
