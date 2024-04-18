{ inputs, outputs }:
let
  inherit (inputs.nixpkgs.lib) mapAttrs;

  getCfg = _: cfg: cfg.config.system.build.toplevel;
in
{
  hosts = mapAttrs getCfg outputs.nixosConfigurations;
  formatter = outputs.formatter;
}
