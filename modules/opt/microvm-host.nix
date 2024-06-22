{
  config,
  lib,
  inputs,
  ...
}:
let
  cfg = config.rad-dev.microvm-host;
  microvm = inputs.microvm.nixosModules;
in
{
  imports = [ microvm.host ];
  options.rad-dev.microvm-host = {
    vms = lib.mkOption {
      type = lib.types.attrset;
      default = { };
      description = "A list of VMs to construct on the host";
    };
  };
  config = {
    networking.useNetworkd = true;
    microvm.vms = cfg.vms;
    microvm.shares = [
      {
        tag = "ro-store";
        source = "/nix/store";
        mountPoint = "/nix/.ro-store";
      }
    ];

    # TODO: deprecate this once we have syslog forwarders
    systemd.tmpfiles.rules = map (
      vmHost:
      let
        machineId = lib.addresses.machineId.${vmHost};
      in
      # creates a symlink of each MicroVM's journal under the host's /var/log/journal
      "L+ /var/log/journal/${machineId} - - - - /var/lib/microvms/${vmHost}/journal/${machineId}"
    ) (builtins.attrNames lib.addresses.machineId);
  };
}
