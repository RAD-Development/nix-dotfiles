{ pkgs, ... }:
{
  time.timeZone = "America/New_York";
  console.keyMap = "us";
  networking.hostId = "dc2f9781";
  boot = {
    zfs.extraPools = [ "ZFS-primary" ];
    loader.grub.device = "/dev/sda";
    filesystem = "zfs";
    useSystemdBoot = true;
    kernelParams = [
      "i915.force_probe=56a5"
      "i915.enable_guc=2"
    ];
  };

  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };
  hardware.opengl = {
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
  hardware.enableAllFirmware = true;

  virtualisation = {
    docker = {
      enable = true;
      recommendedDefaults = true;
      logDriver = "local";
      daemon."settings" = {
        experimental = true;
        exec-opts = [ "native.cgroupdriver=systemd" ];
        log-opts = {
          max-size = "10m";
          max-file = "5";
        };
        data-root = "/var/lib/docker2";
      };
      storageDriver = "overlay2";
    };

    # Disabling as topgrade apparently prefers podman over docker and now I cant update anything :(
    # podman = {
    #   enable = true;
    #   recommendedDefaults = true;
    # };
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
  };

  networking.firewall.enable = false;

  system.stateVersion = "23.05";
}
