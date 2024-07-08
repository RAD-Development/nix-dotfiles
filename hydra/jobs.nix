{
  inputs,
  outputs,
  systems,
}:
let
  inherit (inputs.nixpkgs) lib;
  pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;

  getCfg = _: cfg: cfg.config.system.build.toplevel;
  hostToAgg = _: cfg: cfg;

  # get per-system check derivation (with optional postfix)
  mapSystems =
    {
      check,
      postfix ? "",
    }:
    (map (system: if postfix == "" then check.${system} else check.${system}.${postfix}) systems);
in
rec {
  inherit (outputs) formatter devShells checks;

  host = lib.mapAttrs getCfg outputs.nixosConfigurations;

  hosts = pkgs.releaseTools.aggregate {
    name = "hosts";
    constituents = lib.mapAttrsToList hostToAgg host;
  };

  devChecks = pkgs.releaseTools.aggregate {
    name = "devChecks";
    constituents = lib.flatten [
      (mapSystems { check = formatter; })
      (mapSystems {
        check = checks;
        postfix = "pre-commit-check";
      })
      (mapSystems {
        check = devShells;
        postfix = "default";
      })
    ];
  };
}
