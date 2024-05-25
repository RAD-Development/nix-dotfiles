{
  config,
  lib,
  pkgs,
  src,
  ...
}:
let
  inherit (lib.rad-dev.microvm) genK3SVM;
in

{
  # rad-dev.microvm-host.enable = true;
  rad-dev.microvm-host.vms =
    genK3SVM (src + "/modules/opt/k3s-server.nix") (src + "/modules/opt/k3s-agent.nix")
      {
        "ph-server-1" = {
          ipv4 = "192.168.69.10";
          server = true;
        };
        # "ph-agent-1" = {
        #   ipv4 = "192.168.69.30";
        # };
      };
}
