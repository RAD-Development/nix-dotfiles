{ config, pkgs, ... }:
{
  time.timeZone = "America/New_York";
  console.keyMap = "us";
  systemd.services.hydra-notify.serviceConfig.EnvironmentFile =
    config.sops.secrets."hydra/environment".path;
  programs.git.lfs.enable = false;
  networking = {
    hostId = "dc2f9781";
    firewall.enable = false;
  };

  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  boot = {
    zfs.extraPools = [ "ZFS-primary" ];
    loader.grub.device = "/dev/sda";
    filesystem = "zfs";
    useSystemdBoot = true;
    kernelParams = [
      "i915.force_probe=56a5"
      "i915.enable_guc=2"
    ];
    kernel.sysctl = {
      "vm.overcommit_memory" = 1;
      "vm.swappiness" = 10;
    };
    binfmt.emulatedSystems = [ "aarch64-linux" ];
  };

  nix = {
    extraOptions = ''
      allowed-uris = github: gitlab: git+https:// git+ssh:// https://
      builders-use-substitutes = true
    '';

    buildMachines = [
      {
        hostName = "localhost";
        maxJobs = 2;
        protocol = "ssh-ng";
        speedFactor = 2;
        systems = [
          "x86_64-linux"
          "aarch64-linux"
        ];

        supportedFeatures = [
          "kvm"
          "nixos-test"
          "big-parallel"
          "benchmark"
        ];
      }
    ];
  };

  hardware = {
    enableAllFirmware = true;
    opengl = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver # LIBVA_DRIVER_NAME=iHD
        vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
        vaapiVdpau
        libvdpau-va-gl
        intel-compute-runtime
        intel-media-sdk
      ];
    };
  };

  virtualisation = {
    # Disabling Podman as topgrade apparently prefers podman over docker and now I cant update anything :(
    docker = {
      enable = true;
      recommendedDefaults = true;
      logDriver = "local";
      storageDriver = "overlay2";
      daemon."settings" = {
        experimental = true;
        data-root = "/var/lib/docker2";
        exec-opts = [ "native.cgroupdriver=systemd" ];
        log-opts = {
          max-size = "10m";
          max-file = "5";
        };
      };
    };
  };

  environment.systemPackages = with pkgs; [
    attic-client
    attic
    docker-compose
    jellyfin-ffmpeg
  ];

  services = {
    samba.enable = true;
    nfs.server.enable = true;
    openssh.ports = [ 666 ];
    smartd.enable = true;
    zfs = {
      trim.enable = true;
      autoScrub.enable = true;
    };

    postgresql = {
      enable = true;
      enableJIT = true;
      identMap = ''
        # ArbitraryMapName systemUser DBUser
           superuser_map      root      postgres
           superuser_map      alice  postgres
           # Let other names login as themselves
           superuser_map      /^(.*)$   \1
      '';

      ensureDatabases = [ "atticd" ];
      ensureUsers = [
        {
          name = "atticd";
          ensureDBOwnership = true;
        }
      ];

      # initialScript = config.sops.secrets."postgres/init".path;

      upgrade = {
        enable = true;
        stopServices = [
          "hydra-evaluator"
          "hydra-init"
          "hydra-notify"
          "hydra-queue-runner"
          "hydra-send-stats"
          "hydra-server"
          "atticd"
        ];
      };
    };

    hydra = {
      enable = true;
      hydraURL = "http://localhost:3000";
      smtpHost = "alicehuston.xyz";
      notificationSender = "hydra@alicehuston.xyz";
      gcRootsDir = "/ZFS/ZFS-primary/hydra";
      useSubstitutes = true;
      minimumDiskFree = 50;
      minimumDiskFreeEvaluator = 100;
    };

    nix-serve = {
      enable = true;
      secretKeyFile = config.sops.secrets."nix-serve/secret-key".path;
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
  systemd.services.attic-watch-store = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    requires = [ "network-online.target" ];
    description = "Upload all store content to binary catch";
    serviceConfig = {
      User = "root";
      Restart = "always";
      ExecStart = "${pkgs.attic}/bin/attic watch-store cache-nix-dot";
    };
  };

  sops = {
    defaultSopsFile = ./secrets.yaml;
    secrets = {
      "hydra/environment".owner = "hydra";
      "nix-serve/secret-key".owner = "root";
      "attic/secret-key".owner = "root";
      "attic/database-url".owner = "root";
      "postgres/init".owner = "postgres";
    };
  };

  system.stateVersion = "23.05";
}
