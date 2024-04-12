{ pkgs, ... }:
# home manager
{
  imports = [
    ./home/sshconfig.nix
    ./home/git.nix
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
    packages = with pkgs; [
      firefox
      # Rust packages
      topgrade
      trunk
      wasm-pack
      cargo-watch
      cargo-generate
      cargo-audit
      cargo-update
    ];
  };

  home.stateVersion = "23.11";
}
