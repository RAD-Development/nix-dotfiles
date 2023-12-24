{ pkgs, ... }:
{
  time.timeZone = "America/New_York";
  console.keyMap = "us";

  virtualisation = {
    docker = {
      enable = true;
      recommendedDefaults = true;
      logDriver = "local";
      daemon."settings" = {
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

    haproxy = {
      enable = true;
      config = builtins.readFile ./conf/haproxy.conf;
    };
  };

  networking.firewall.enable = false;

  system.stateVersion = "23.05";
}