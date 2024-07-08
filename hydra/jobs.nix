{ inputs, outputs }:
let
  inherit (inputs.nixpkgs.lib) mapAttrs mapAttrsToList;
  pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;

  getCfg = _: cfg: cfg.config.system.build.toplevel;
in
rec {
  inherit (outputs) formatter devShells checks;

  hosts = pkgs.releaseTools.aggregate {
    name = "hosts";
    constituents = mapAttrsToList getCfg outputs.nixosConfigurations;
  };
}
// (mapAttrs getCfg outputs.nixosConfigurations)
