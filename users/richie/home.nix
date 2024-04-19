{
  imports = [
    ./home/programs.nix
    ./home/sshconfig.nix
    ./home/cli
    ./home/vscode
  ];

  nixpkgs.config.allowUnfree = true;

  home = {
    username = "richie";
    homeDirectory = "/home/richie";
  };

  home.stateVersion = "23.11";
}
