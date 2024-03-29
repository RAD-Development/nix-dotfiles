{ pkgs, ... }:

{
  imports = [
    ./home/zsh.nix
    ./home/doom
  ];

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
      cmake
      shellcheck
      glslang
      gnumake
      pipenv
      python312
      python312Packages.isort
      python312Packages.pynose
      python312Packages.pytest
      shellcheck

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
    emacs = {
      enable = true;
      package = pkgs.emacs29-pgtk;
    };

    starship.enable = true;
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
      vimdiffAlias = true;
      extraConfig = ''
        set bg=dark
              set tabstop=2
        	set shiftwidth=2
        	set expandtab
        	set smartindent
      '';
    };
    nix-index = {
      enable = true;
      enableZshIntegration = true;
    };

    tmux.enable = true;
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

  # TODO: add environment bs
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  home.stateVersion = "23.11";
}
