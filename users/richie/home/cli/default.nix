{
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkIf;
in {
  imports = [
    ./git.nix
    ./zsh.nix
  ];

  programs.starship.enable = true;

}
