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
  };

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

    podman = {
      enable = true;
      recommendedDefaults = true;
    };
  };

  environment.systemPackages = with pkgs; [
    docker-compose
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
