{ config, pkgs, ... }: {
  time.timeZone = "America/New_York";
  console.keyMap = "us";
  systemd.services.hydra-notify.serviceConfig.EnvironmentFile = config.sops.secrets."hydra/environment".path;
  programs.git.lfs.enable = false;
  networking = {
    hostId = "dc2f9781";
    firewall.enable = false;
  };

  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override {
      enableHybridCodec = true;
    };
  };

  boot = {
    zfs.extraPools = [ "ZFS-primary" ];
    loader.grub.device = "/dev/sda";
    filesystem = "zfs";
    useSystemdBoot = true;
    kernelParams = [ "i915.force_probe=56a5" "i915.enable_guc=2" ];
    binfmt.emulatedSystems = [ "aarch64-linux" ];
  };

  nix = {
    extraOptions = ''
      allowed-uris = github: gitlab: git+https:// git+ssh:// https://
      builders-use-substitutes = true
    '';

    buildMachines = [{
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
    }];
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

      upgrade = {
        enable = true;
        stopServices = [ "hydra" ];
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

      # Replace with absolute path to your credentials file
      credentialsFile = config.sops.secrets."attic/secret-key".path;

      settings = {
        listen = "[::]:8083";

        # Data chunking
        #
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

  sops = {
    defaultSopsFile = ./secrets.yaml;
    secrets = {
      "hydra/environment".owner = "hydra";
      "nix-serve/secret-key".owner = "root";
      "attic/secret-key".owner = "root";
    };
  };

  system.stateVersion = "23.05";
}
