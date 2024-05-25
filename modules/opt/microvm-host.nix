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
      type = lib.types.attrs;
      default = { };
      description = "A list of VMs to construct on the host";
    };
  };
  config = {
    networking.useNetworkd = true;
    microvm.vms = cfg.vms;

    # TODO: deprecate this once we have syslog forwarders
    systemd.tmpfiles.rules = map (
      vmHost:
      let
        machineId = cfg.vms.${vmHost}.config.environment.etc."machine-id".text;
      in
      # creates a symlink of each MicroVM's journal under the host's /var/log/journal
      "L+ /var/log/journal/${machineId} - - - - /var/lib/microvms/${vmHost}/journal/${machineId}"
    ) (builtins.attrNames cfg.vms);
  };
}
