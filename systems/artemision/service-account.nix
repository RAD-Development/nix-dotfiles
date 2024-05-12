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
        enable = true;
        enable-docker = true;
        zerotier-networks = [ "e4da7455b2ae64ca" ];
      };
    };
  };
}
