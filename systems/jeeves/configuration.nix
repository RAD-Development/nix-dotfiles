{ pkgs, ... }:
let
  vars = import ./vars.nix;
in
{
  imports = [
    ../../users/richie/global/ssh.nix
    ../../users/richie/global/syncthing_base.nix
    ../../users/richie/global/zerotier.nix
    ./docker
    ./programs.nix
  ];

  networking = {
    hostId = "1beb3027";
    firewall.enable = false;
  };

  boot = {
    zfs.extraPools = [
      "media"
      "storage"
      "torrenting"
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
    variables = {
      ZFS_MEDIA = vars.zfs_media;
      ZFS_STORAGE = vars.zfs_storage;
      ZFS_STORAGE_PLEX = vars.storage_plex;
      ZFS_TORRENTING = vars.zfs_torrenting;
    };
  };

  services = {
    nfs.server.enable = true;

    openssh.ports = [ 629 ];

    plex = {
      enable = true;
      dataDir = vars.media_plex;
    };

    smartd.enable = true;

    sysstat.enable = true;

    syncthing.guiAddress = "192.168.90.40:8384";
    syncthing.settings.folders = {
      "notes" = {
        id = "l62ul-lpweo"; # cspell:disable-line
        path = vars.media_notes;
        devices = [
          "bob"
          "phone"
          "rhapsody-in-green"
        ];
        fsWatcherEnabled = true;
      };
      "books" = {
        id = "6uppx-vadmy"; # cspell:disable-line
        path = "${vars.storage_syncthing}/books";
        devices = [
          "bob"
          "phone"
          "rhapsody-in-green"
        ];
        fsWatcherEnabled = true;
      };
      "important" = {
        id = "4ckma-gtshs"; # cspell:disable-line
        path = "${vars.storage_syncthing}/important";
        devices = [
          "bob"
          "phone"
          "rhapsody-in-green"
        ];
        fsWatcherEnabled = true;
      };
      "music" = {
        id = "vprc5-3azqc"; # cspell:disable-line
        path = "${vars.storage_syncthing}/music";
        devices = [
          "bob"
          "phone"
          "rhapsody-in-green"
        ];
        fsWatcherEnabled = true;
      };
      "projects" = {
        id = "vyma6-lqqrz"; # cspell:disable-line
        path = "${vars.storage_syncthing}/projects";
        devices = [
          "bob"
          "rhapsody-in-green"
        ];
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
        Environment = "ZFS_BIN=${pkgs.zfs}/bin/zfs";
        Type = "oneshot";
        ExecStart = "${pkgs.python3}/bin/python3 /zfs/media/scripts/ZFS/snapshot_manager.py --config-file='/root/nix-dotfiles/systems/jeeves/snapshot_config.toml'";
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

  sops = {
    defaultSopsFile = ./secrets.yaml;
    secrets = {
      "zfs/backup_key".path = "/root/zfs/backup_key";
      "zfs/docker_key".path = "/root/zfs/docker_key";
      "zfs/main_key".path = "/root/zfs/main_key";
      "zfs/notes_key".path = "/root/zfs/notes_key";
      "zfs/plex_key".path = "/root/zfs/plex_key";
      "zfs/postgres_key".path = "/root/zfs/postgres_key";
      "zfs/qbit_key".path = "/root/zfs/qbit_key";
      "zfs/scripts_key".path = "/root/zfs/scripts_key";
      "zfs/syncthing_key".path = "/root/zfs/syncthing_key";
      "zfs/vault_key".path = "/root/zfs/vault_key";
    };
  };

  system.stateVersion = "23.11";
}
