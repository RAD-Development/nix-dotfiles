{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./hydra.nix
    ./networking.nix
    ./nextcloud.nix
    ./zfs.nix
  ];

  programs.git.lfs.enable = false;

  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  boot = {
    loader.grub.device = "/dev/sda";
    useSystemdBoot = true;
    kernelParams = [
      "i915.force_probe=56a5"
      "i915.enable_guc=2"
    ];
    kernel.sysctl = {
      "vm.overcommit_memory" = lib.mkForce 1;
      "vm.swappiness" = 10;
    };
    binfmt.emulatedSystems = [ "aarch64-linux" ];
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

  virtualisation.docker.daemon.settings.data-root = "/var/lib/docker2";

  environment.systemPackages = with pkgs; [
    attic-client
    attic
    docker-compose
    intel-gpu-tools
    jellyfin-ffmpeg
    jq
  ];

  services = {
    samba.enable = true;
    nfs.server.enable = true;
    openssh.ports = [ 666 ];
    smartd.enable = true;

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
  };

  nix.gc.options = "--delete-older-than 150d";

  # TODO: revert this once UPS is plugged in
  # Not reverting this before the merge as the UPS not being plugged in is
  # causing upgrades to fail
  power.ups = {
    enable = false;
    ups."LX1325GU3" = {
      driver = "usbhid-ups";
      port = "auto";
      description = "CyberPower LX1325GU3";
    };
    users.upsmon = {
      passwordFile = config.sops.secrets."upsmon/password".path;
      upsmon = "primary";
    };
    upsmon.monitor."LX1325GU3".user = "upsmon";
  };

  sops = {
    defaultSopsFile = ./secrets.yaml;
    secrets = {
      "postgres/init".owner = "postgres";
      "upsmon/password".owner = "root";
    };
  };

  system.stateVersion = "23.05";
}
