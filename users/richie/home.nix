{ pkgs, ... }:

{
  home.username = "richie";
  home.homeDirectory = "/home/richie";

  home.packages = with pkgs; [
    # Rust packages
    topgrade
    trunk
    wasm-pack
    cargo-watch
    # pkgs.cargo-tarpaulin
    cargo-generate
    cargo-audit
    cargo-update
    diesel-cli
    # gitoxide currently broke 09182023
    gitoxide
    tealdeer
    helix

    # nix specific packages
    nil
    nixfmt

    # markdown
    nodePackages.markdownlint-cli

    # doom emacs dependencies
    fd
    ripgrep
    clang
  ];

  programs.zsh.enable = true;

  home.stateVersion = "23.11";
}
