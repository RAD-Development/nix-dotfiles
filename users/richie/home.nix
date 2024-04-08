{ pkgs, ... }:
# home manager
{
  programs.zsh.enable = true;
  home = {
    username = "richie";
    homeDirectory = "/home/richie";
    packages = with pkgs; [
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
