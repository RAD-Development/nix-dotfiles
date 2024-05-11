{
  imports = [
    ./git.nix
    ./zsh.nix
    ./direnv.nix
  ];

  programs.starship.enable = true;
}
