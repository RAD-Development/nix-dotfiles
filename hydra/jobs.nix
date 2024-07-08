{ inputs, outputs }:
let
  inherit (inputs.nixpkgs.lib) mapAttrsToList;
  pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;

  getCfg = _: cfg: cfg.config.system.build.toplevel;
in
rec {
  inherit (outputs) formatter devShells checks;

  machines = mapAttrsToList getCfg outputs.nixosConfigurations;

  hosts = pkgs.releaseTools.aggregate {
    name = "hosts";
    constituents = machines;
  };
}
