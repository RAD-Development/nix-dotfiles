{
  config,
  lib,
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    attic-client
    attic
  ];

  services = {
    postgresql = {
      enable = true;
      ensureDatabases = [ "atticd" ];
      ensureUsers = [
        {
          name = "atticd";
          ensureDBOwnership = true;
        }
      ];
      upgrade = {
        enable = true;
        stopServices = [ "atticd" ];
      };
    };

    atticd = {
      enable = true;

      credentialsFile = config.sops.secrets."attic/secret-key".path;

      settings = {
        listen = "[::]:8183";
        allowed-hosts = [ "attic.alicehuston.xyz" ];
        api-endpoint = "https://attic.alicehuston.xyz";
        compression.type = "none"; # let ZFS do the compressing
        database = {
          url = "postgres://atticd?host=/run/postgresql";
          # disable postgres, using SOPS fails at below :(
          # https://github.com/zhaofengli/attic/blob/main/nixos/atticd.nix#L57
          # url = "sqlite:///ZFS/ZFS-primary/attic/server.db?mode=rwc";
          heartbeat = true;
        };
        storage = {
          type = "local";
          path = "/ZFS/ZFS-primary/attic/storage";
        };

        # Warning: If you change any of the values here, it will be
        # difficult to reuse existing chunks for newly-uploaded NARs
        # since the cutpoints will be different. As a result, the
        # deduplication ratio will suffer for a while after the change.
        chunking = {
          # The minimum NAR size to trigger chunking
          #
          # If 0, chunking is disabled entirely for newly-uploaded NARs.
          # If 1, all NARs are chunked.
          nar-size-threshold = 64 * 1024; # 64 KiB

          # The preferred minimum size of a chunk, in bytes
          min-size = 16 * 1024; # 16 KiB

          # The preferred average size of a chunk, in bytes
          avg-size = 64 * 1024; # 64 KiB

          # The preferred maximum size of a chunk, in bytes
          max-size = 256 * 1024; # 256 KiB
        };
      };
    };

  };

  # borrowing from https://github.com/Shawn8901/nix-configuration/blob/4b8d1d44f47aec60feb58ca7b7ab5ed000506e90/modules/nixos/private/hydra.nix
  # configured default webstore for this on root user separately
  systemd = {
    services = {
      attic-watch-store = {
        wantedBy = [ "multi-user.target" ];
        after = [
          "network-online.target"
          "docker.service"
          "atticd.service"
        ];
        requires = [
          "network-online.target"
          "docker.service"
          "atticd.service"
        ];
        description = "Upload all store content to binary cache";
        serviceConfig = {
          User = "root";
          Restart = "always";
          ExecStart = "${pkgs.attic}/bin/attic watch-store cache-nix-dot";
        };
      };
      attic-sync-hydra = {
        after = [
          "network-online.target"
          "docker.service"
          "atticd.service"
        ];
        requires = [
          "network-online.target"
          "docker.service"
          "atticd.service"
        ];
        description = "Force resync of hydra derivations with attic";
        serviceConfig = {
          Type = "oneshot";
          DynamicUser = "yes";
          Group = "hydra";
          ReadWriteDirectories = "-//.cache";
          ExecStart = "${config.nix.package}/bin/nix ${./attic/sync-attic.bash}";
        };
      };
    };

    timers = {
      attic-sync-hydra = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = 600;
          OnUnitActiveSec = 86400;
          Unit = "attic-sync-hydra.service";
        };
      };
    };
  };

  sops = {
    defaultSopsFile = ./secrets.yaml;
    secrets = {
      "attic/secret-key".owner = "root";
      "attic/database-url".owner = "root";
    };
  };
}
