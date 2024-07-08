{ inputs, outputs }:
let
  inherit (inputs.nixpkgs.lib) mapAttrs mapAttrsToList;
  pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;

  getCfg = _: cfg: cfg.config.system.build.toplevel;
  hostToAgg = _: cfg: cfg;
in
rec {
  inherit (outputs) formatter devShells checks;

  host = mapAttrs getCfg outputs.nixosConfigurations;

  hosts = pkgs.releaseTools.aggregate {
    name = "hosts";
    constituents = mapAttrsToList hostToAgg host;
  };

  devChecks = pkgs.releaseTools.aggregate {
    name = "devChecks";
    constituents = [
      formatter.x86_64-linux
      devShells.x86_64-linux
      checks.x86_64-linux
    ];
  };
}
