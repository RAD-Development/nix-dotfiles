{ lib, ... }:
rec {
  genK3SVM =
    server-config: agent-config: vms:
    lib.mapAttrs (
      host:
      {
        ipv4,
        machine-id,
        server ? false,
      }:
      genMicroVM host ipv4 "x86_64-linux" machine-id (if server then server-config else agent-config)
    ) vms;

  genMicroVM =
    hostName: ipv4: _system: machine-id: vm-config:
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
        imports = [ vm-config ];
        # It is highly recommended to share the host's nix-store
        # with the VMs to prevent building huge images.

        system.stateVersion = "24.05";

        environment.etc."machine-id" = {
          mode = "0644";
          text = machine-id + "\n";
        };

        microvm.shares = [
          {
            source = "/nix/store";
            mountPoint = "/nix/.ro-store";
            tag = "ro-store";
            proto = "virtiofs";
          }
          {
            # On the host
            source = "/var/lib/microvms/${hostName}/journal";
            # In the MicroVM
            mountPoint = "/var/log/journal";
            tag = "journal";
            proto = "virtiofs";
            socket = "journal.sock";
          }
        ];

        networking = {
          inherit hostName;
          interfaces.ether.ipv4.addresses = [
            {
              address = ipv4;
              prefixLength = 32;
            }
          ];
        };

        services.openssh.enable = true;
        users.users.alice = {
          openssh.authorizedKeys.keys = [
            # photon
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOGcqhLaKsjwAnb6plDavAhEyQHNvFS9Uh5lMTuwMhGF alice@parthenon-7588"
            # gh
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGoaEmzaS9vANckvBmqrYSHdFR0sPL4Xgeonbh9KcgFe gitlab keypair"
            # janus
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAfcO9p5opG8Tym6tcLkat6YGCcE6vwg0+V4MTC5WKop alice@parthenon-7588"
            # palatine
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP59pDsx34k2ikrKa0eVacj0APSGivaij3lP9L0Zd9au alice@parthenon-7588"
            # jeeves
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJDgkUndkfns6f779T5ckHOVhyOKP8GttQ9RfaO9uJdx alice@parthenon-7588"
          ];
          isNormalUser = true;
        };
        # Any other configuration for your MicroVM
        # [...]
      };
    };
}
