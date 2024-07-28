{
  inputs,
  forEachSystem,
  checks,
  ...
}:

forEachSystem (
  system:
  let
    inherit (inputs) nixpkgs sops-nix;
    pkgs = nixpkgs.legacyPackages.${system};

    # construct the shell provided by pre-commit for running hooks
    pre-commit = pkgs.mkShell {
      shellHook = ''
        if [ -f ./.noprecommit ]; then
          echo ".noprecommit found! Delete this file to re-install pre-commit hooks"
          if [ -f ./.pre-commit-config.yaml ]; then
            echo "uninstalling pre-commit hooks"
            pre-commit uninstall
            rm .pre-commit-config.yaml
          fi
        else
          ${checks.${system}.pre-commit-check.shellHook}
        fi
      '';
      buildInputs = checks.${system}.pre-commit-check.enabledPackages;
    };

    # construct a shell for importing sops keys (also provides the sops binary)
    sops = pkgs.mkShell {
      sopsPGPKeyDirs = [ "./keys" ];
      packages = [
        pkgs.sops
        sops-nix.packages.${system}.sops-import-keys-hook
      ];
    };

    # constructs a custom shell with commonly used utilities
    rad-dev = pkgs.mkShell {
      packages = with pkgs; [
        deadnix
        pre-commit
        treefmt
        statix
        nixfmt-rfc-style
      ];
    };
  in
  {
    default = pkgs.mkShell {
      inputsFrom = [
        pre-commit
        rad-dev
        sops
      ];
    };
  }
)
