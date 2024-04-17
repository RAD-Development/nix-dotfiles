{
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkIf;
in {
  imports = [
    ./git.nix
    ./starship.nix
    ./zsh.nix
  ];
}
