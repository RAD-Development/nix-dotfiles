{
  imports = [
    ./home/git.nix
    ./home/programs.nix
    ./home/sshconfig.nix
    ./home/vscode
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  programs.zsh.enable = true;
  home = {
    username = "richie";
    homeDirectory = "/home/richie";
  };

  home.stateVersion = "23.11";
}
