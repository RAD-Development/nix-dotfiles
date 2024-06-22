{
  config,
  lib,
  inputs,
  ...
}:
let
  cfg = config.rad-dev.microvm-host;
  inherit (inputs.microvm.nixosModules) microvm;
in
{
  # imports = [microvm.host];
  options.rad-dev.microvm-host = {
    enable = lib.mkEnableOption "microvm-host";
  };
  config = lib.mkIf cfg.enable {
    networking.useNetworkd = true;
    # microvm.shares = [
    #   {
    #     tag = "ro-store";
    #     source = "/nix/store";
    #     mountPoint = "/nix/.ro-store";
    #   }
    # ];
    #     systemd.tmpfiles.rules = map (vmHost:
    #   let
    #     machineId = lib.addresses.machineId.${vmHost};
    #   in
    #     # creates a symlink of each MicroVM's journal under the host's /var/log/journal
    #     "L+ /var/log/journal/${machineId} - - - - /var/lib/microvms/${vmHost}/journal/${machineId}"
    # ) (builtins.attrNames lib.addresses.machineId);
  };
}
