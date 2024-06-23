{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [ ./archiveteam.nix ];

  virtualisation.oci-containers.backend = "docker";
}
