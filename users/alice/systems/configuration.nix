{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [ ./non-server.nix ];

  services.fwupd.enable = true;
}
