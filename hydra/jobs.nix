{ inputs, outputs }:
let
  inherit (inputs.nixpkgs.lib) mapAttrs;

  getCfg = _: cfg: cfg.config.system.build.toplevel;
in
{
  inherit (outputs) formatter devShells;
  hosts = mapAttrs getCfg outputs.nixosConfigurations;
}
