{ config, pkgs, ... }:

{
  imports = [
    ./home/zsh.nix
    ./home/doom
    ./home/gammastep.nix
    ./home/git.nix
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

      # useful tools
      ncdu
      neofetch
      smartmontools
      wget
      zsh-nix-shell
      glances

      # Rust packages
      bat
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
      eza

      # nix specific packages
      nil
      nixfmt-rfc-style
      nix-init
      nix-output-monitor
      nix-prefetch
      nix-tree

      # markdown
      nodePackages.markdownlint-cli

      # doom emacs dependencies
      fd
      ripgrep
      clang
      yaml-language-server
      nodePackages.typescript-language-server

      # audit
      lynis

      # dependencies for nix-dotfiles/hydra-check-action
      nodejs_20
      nodePackages.prettier
      treefmt
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

  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
      extraConfig = {
        XDG_SCREENSHOTS_DIR = "${config.xdg.userDirs.pictures}/Screenshots";
      };
    };
  };

  home.stateVersion = "23.11";
}
