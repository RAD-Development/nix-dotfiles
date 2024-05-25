{ lib, ... }:
rec {
  genK3SVM =
    server-config: agent-config: vms:
    lib.mapAttrs (
      host: {ipv4,server ? false}:
      genMicroVM host ipv4 "x86_64-linux" (
        if server then (import server-config) else (import agent-config)
      )
    ) vms;

  genMicroVM =
    hostName: ipv4: system: vm-config:
    # microvm refers to microvm.nixosModules

    # {
    #   config,
    #   pkgs,
    #   lib,
    #   ...
    # }:
    {
        # The package set to use for the microvm. This also determines the microvm's architecture.
        # Defaults to the host system's package set if not given.
        # pkgs = import pkgs { inherit system; };

        # (Optional) A set of special arguments to be passed to the MicroVM's NixOS modules.
        #specialArgs = {};

        # The configuration for the MicroVM.
        # Multiple definitions will be merged as expected.
        config = {
          # It is highly recommended to share the host's nix-store
          # with the VMs to prevent building huge images.
          microvm.shares = [
            {
              source = "/nix/store";
              mountPoint = "/nix/.ro-store";
              tag = "ro-store";
              proto = "virtiofs";
            }
          ];

          networking = {
            inherit hostName;
            interfaces.ether.ipv4.addreses = {
              address = ipv4;
              prefixLength = 32;
            };
          };

          # Any other configuration for your MicroVM
          # [...]
        } // vm-config;
    };
}
