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
      # Example custom hook for nix formatting:
      fmt-check = {
        enable = true;

        # The command to execute (mandatory):
        entry = "${formatter.${system}}/bin/nixfmt --check";

        # The pattern of files to run on (default: "" (all))
        # see also https://pre-commit.com/#hooks-files
        files = "\\.nix$";
      };
      nil.enable = true;
      statix.enable = false;

      # json hooks
      check-json.enable = true;

      # git hooks
      check-merge-conflicts.enable = true;
      no-commit-to-branch.enable = true;

      # misc hooks
      check-added-large-files.enable = true;
      check-case-conflicts.enable = true;
      detect-private-keys.enable = true;
    };
  };
})
