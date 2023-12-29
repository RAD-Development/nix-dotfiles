{ pkgs, ... }:
{
  time.timeZone = "America/New_York";
  console.keyMap = "us";
  networking.hostId = "1beb3026";

  boot = {
    # TODO add pool name
    zfs.extraPools = [  ];
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
        data-root = "/var/lib/docker";
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
    nfs.server.enable = true;

    openssh.ports = [ 352 ];
    smartd.enable = true;
    zfs = {
      trim.enable = true;
      autoScrub.enable = true;
    };
  };

  networking.firewall.enable = false;

  system.stateVersion = "23.05";
}
