{
  inputs,
  forEachSystem,
  formatter,
  ...
}:
forEachSystem (system: {
  pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
    src = ./.;
    hooks = {
      # nix checks
      # Example custom hook for nix formatting
      fmt-check = {
        enable = true;

        # The command to execute (mandatory):
        entry = "${formatter.${system}}/bin/nixfmt --check";

        # The pattern of files to run on (default: "" (all))
        # see also https://pre-commit.com/#hooks-files
        files = "\\.nix$";
      };
      ## static analysis checks for nix
      nil.enable = true;
      statix.enable = true;
      deadnix = {
        enable = true;
        settings = {
          noUnderscore = true; # ignore variables starting with underscore
          # ignore lambda patterns (useful for passing args from ({}@args)
          # to other functions)
          noLambdaPatternNames = true;
        };
      };

      # json hooks
      check-json = {
        enable = true;
        # exclude vscode json files as they allow comments and check-json doesn't
        excludes = [ "settings.json$" ];
      };

      # toml hooks
      check-toml.enable = true;

      # git hooks
      check-merge-conflicts.enable = true;
      ## prevents committing to main
      no-commit-to-branch.enable = true;

      # misc hooks
      check-added-large-files.enable = true;
      ## prevents two similarly named files for case sensitive systems
      check-case-conflicts.enable = true;
      detect-private-keys.enable = true;
    };
  };
})
