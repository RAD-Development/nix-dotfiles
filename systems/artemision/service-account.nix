{
  config,
  lib,
  pkgs,
  ...
}:

{
  rad-dot.service-accounts = {
    enable = true;
    accounts = {
      docker-deploy = {
        enable = false;
        enable-docker = true;
        enable-podman = false;
      };
    };
  };
}
