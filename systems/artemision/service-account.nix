{
  config,
  lib,
  pkgs,
  ...
}:

{
  rad-dot.service-accounts.docker-deploy = {
    enable = true;
    account-name = "docker-deploy";
    enable-docker = true;
    zerotier-networks = [ "e4da7455b2ae64ca" ];
  };
}
