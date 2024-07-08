{ inputs, outputs }:
let
  inherit (inputs.nixpkgs.lib) mapAttrs;
  pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;

  getCfg = _: cfg: cfg.config.system.build.toplevel;
in
{
  inherit (outputs) formatter devShells checks;
  hosts = pkgs.releaseTools.aggregate {
    name = "hosts";
    constituents = mapAttrs getCfg outputs.nixosConfigurations;
  };
}
