{ config, lib, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "alice";
  home.homeDirectory = "/home/alice";

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')

    # Rust packages
    topgrade
    trunk
    wasm-pack
    cargo-watch
    #pkgs.cargo-tarpaulin
    cargo-generate
    cargo-audit
    cargo-update
    diesel-cli
    # gitoxide currently broke 09182023
    gitoxide
    tealdeer
    helix

    # pipx packages
    # Not sure that I need these right now
    #python311Packages.python-lsp-server
    #python311Packages.pycodestyle

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

  home.stateVersion = "23.05";
  # Let Home Manager install and manage itself.
  # programs.home-manager.enable = false;
}
