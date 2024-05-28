{ pkgs, ... }:
{
  imports = [
    ../../users/richie/global/syncthing_base.nix
    ../../users/richie/global/zerotier.nix
    ./docker
  ];

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

    syncthing.guiAddress = "192.168.90.40:8384";
    syncthing.settings.folders = {
      "notes" = {
        id = "l62ul-lpweo"; # cspell:disable-line
        path = "/ZFS/Media/Notes";
        devices = [
          "phone"
          "rhapsody-in-green"
        ];
        fsWatcherEnabled = true;
      };
      "books" = {
        id = "6uppx-vadmy"; # cspell:disable-line
        path = "/ZFS/Storage/Syncthing/books";
        devices = [
          "phone"
          "rhapsody-in-green"
        ];
        fsWatcherEnabled = true;
      };
      "important" = {
        id = "4ckma-gtshs"; # cspell:disable-line
        path = "/ZFS/Storage/Syncthing/important";
        devices = [
          "phone"
          "rhapsody-in-green"
        ];
        fsWatcherEnabled = true;
      };
      "music" = {
        id = "vprc5-3azqc"; # cspell:disable-line
        path = "/ZFS/Storage/Syncthing/music";
        devices = [
          "phone"
          "rhapsody-in-green"
        ];
        fsWatcherEnabled = true;
      };
      "projects" = {
        id = "vyma6-lqqrz"; # cspell:disable-line
        path = "/ZFS/Storage/Syncthing/projects";
        devices = [ "rhapsody-in-green" ];
        fsWatcherEnabled = true;
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
  };
  systemd = {
    services."snapshot_manager" = {
      description = "ZFS Snapshot Manager";
      requires = [ "zfs-import.target" ];
      after = [ "zfs-import.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.python3}/bin/python -m zfs.snapshot_manager --config-file='/ZFS/Media/Scripts/new/config.toml'";
      };
    };
    timers."snapshot_manager" = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "15m";
        OnUnitActiveSec = "15m";
        Unit = "snapshot_manager.service";
      };
    };
  };

  system.stateVersion = "23.11";
}
