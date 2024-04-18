{ lib, ... }:
{
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
