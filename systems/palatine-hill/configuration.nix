{ config, pkgs, ... }: {
  time.timeZone = "America/New_York";
  console.keyMap = "us";
  networking.hostId = "dc2f9781";
  boot = {
    zfs.extraPools = [ "ZFS-primary" ];
    loader.grub.device = "/dev/sda";
    filesystem = "zfs";
    useSystemdBoot = true;
    kernelParams = [ "i915.force_probe=56a5" "i915.enable_guc=2" ];
  };

  nix = {
    extraOptions = ''
      allowed-uris = github: gitlab: git+https:// git+ssh:// https://
    '';

    buildMachines = [{
      hostName = "localhost";
      maxJobs = 2;
      protocol = "ssh-ng";
      speedFactor = 2;
      supportedFeatures = [ "kvm" "nixos-test" "big-parallel" "benchmark" ];
      system = "x86_64-linux";
    }];
  };

  nixpkgs.config.packageOverrides = pkgs: { vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; }; };

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

    # Disabling as topgrade apparently prefers podman over docker and now I cant update anything :(
    # podman = {
    #   enable = true;
    #   recommendedDefaults = true;
    # };
  };

  environment.systemPackages = with pkgs; [ docker-compose jellyfin-ffmpeg ];

  systemd.services.hydra-notify = { serviceConfig.EnvironmentFile = config.sops.secrets."hydra/environment".path; };

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
      gcRootsDir = "/ZFS/ZFS-Primary/hydra";
      buildMachinesFiles = [ ];
      useSubstitutes = true;
      minimumDiskFree = 50;
      minimumDiskFreeEvaluator = 100;
    };

    nix-serve = {
      enable = true;
      secretKeyFile = config.sops.secrets."nix-serve/secret-key".path;
    };
  };

  networking.firewall.enable = false;

  sops = {
    defaultSopsFile = ./secrets.yaml;
    secrets = {
      "hydra/environment".owner = "hydra";
      "nix-serve/secret-key".owner = "root";
    };
  };

  system.stateVersion = "23.05";
}
