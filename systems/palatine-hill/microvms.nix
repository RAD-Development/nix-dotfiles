{
  config,
  lib,
  pkgs,
  src,
  ...
}:
let
  inherit (lib.rad-dev.microvm) genK3SFromList;
in

{
  # rad-dev.microvm-host.enable = true;
  rad-dev.microvm-host.vms =
    genK3SFromList (src + "/modules/opt/k3s-server.nix") (src + "/modules/opt/k3s-agent.nix")
      [
        {
          host = "ph-server-1";
          ipv4 = "192.168.69.10";
          server = true;
        }
        {
          host = "ph-agent-1";
          ipv4 = "192.168.69.30";
        }
      ];
}
