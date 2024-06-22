{ lib, ... }:
{
  users = {
    users.docker-service = {
      isSystemUser = true;
      group = "docker-service";
      extraGroups = [ "docker" ];
      uid = 600;
    };
    groups.docker-service = {
      gid = 600;
    };
  };

  virtualisation.docker = {
    enable = lib.mkDefault true;
    logDriver = "local";
    storageDriver = "overlay2";
    daemon.settings = {
      experimental = true;
      exec-opts = [ "native.cgroupdriver=systemd" ];
      log-opts = {
        max-size = "10m";
        max-file = "5";
      };
    };
  };
}
