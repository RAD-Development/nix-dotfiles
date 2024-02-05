{ pkgs, ... }:

{
  home = {
    username = "alice";
    homeDirectory = "/home/alice";
    packages = with pkgs; [
      ncdu

      # Rust packages
      trunk
      wasm-pack
      cargo-watch
      #pkgs.cargo-tarpaulin
      cargo-generate
      cargo-audit
      cargo-update
      diesel-cli
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
  };

  programs = {
    zsh.enable = true;
    starship.enable = true;
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    topgrade = {
      enable = true;
      settings = { misc = { disable = [ "system" "nix" "shell" ]; }; };
    };
  };

  home.stateVersion = "23.11";
}
