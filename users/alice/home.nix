{ pkgs, ... }:

{
  imports = [ ./home/zsh.nix ];

  home = {
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
    starship.enable = true;
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    nix-index = {
      enable = true;
      enableZshIntegration = true;
    };

    topgrade = {
      enable = true;
      settings = {
        misc = {
          disable = [
            "system"
            "nix"
            "shell"
          ];
        };
      };
    };
  };

  services.ssh-agent.enable = true;

  home.stateVersion = "23.11";
}
