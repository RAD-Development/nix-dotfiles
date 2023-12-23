{ pkgs, lib, config, ... }:
let
in {

  i18n = {
    defaultLocale = "en_US.utf8";
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "de_DE.UTF-8/UTF-8"
    ];
  };


  networking.firewall.allowedTCPPorts = [ 22 ];

  services = {
    openssh = {
      enable = true;
      fixPermissions = true;
      extraConfig = ''StreamLocalBindUnlink yes'';
      authorizedKeysFiles = [ "../users/dennis/keys/yubikey.pub" ];
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };
  };

  users.users.brain = {
    isNormalUser = true;
    description = "Administrator";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
  };

  nixpkgs.config.allowUnfree = true;

  programs = {
    fzf.keybindings = true;
    git = {
      enable = true;
      config = {
        alias = {
	        p = "pull";
	        r = "reset --hard";
          ci = "commit";
          co = "checkout";
          lg = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)'";
          st = "status";
          undo = "reset --soft HEAD^";
        };
        interactive.singlekey = true;
        pull.rebase = true;
        rebase.autoStash = true;
        safe.directory = "/etc/nixos";
      };
    };

    zsh = {
      enable = true;
      autosuggestions = {
        enable = true;
        strategy = [ "completion" ];
        async = true;
      };

      syntaxHighlighting.enable = true;
      zsh-autoenv.enable = true;
      enableCompletion = true;
      enableBashCompletion = true;
      ohMyZsh = {
        enable = true;
        plugins = [ "git" "sudo" "docker" "kubectl" "history" "colorize" "direnv" ];
        theme = "agnoster";
      };

      shellAliases = {
	      flake = "nvim flake.nix";
        garbage = "sudo nix-collect-garbage -d";
        gpw = "git pull | grep \"Already up-to-date\" > /dev/null; while [ $? -gt 1 ]; do sleep 5; git pull | grep \"Already up-to-date\" > /dev/null; done; notify-send Pull f$";
        l = "ls -lah";
        nixdir = "echo \"use flake\" > .envrc && direnv allow";
        nixeditc = "nvim ~/dotfiles/system/configuration.nix";
        nixeditpc = "nvim ~/dotfiles/system/program.nix";
        pypi = "pip install --user";
	      qr = "qrencode -m 2 -t utf8 <<< \"$1\"";
        update = "sudo nixos-rebuild switch --fast --flake ~/dotfiles/ -L";
        v = "nvim";
      };
    };

    neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
      viAlias = true;
      withPython3 = true;
      configure = {
        customRC = ''
              set undofile         " save undo file after quit
          	  set undolevels=1000  " number of steps to save
          	  set undoreload=10000 " number of lines to save

          	  " Save Cursor Position
          	  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
          	'';
        packages.myVimPackage = with pkgs.vimPlugins; {
          start = [
            colorizer
            copilot-vim
            csv-vim
            fugitive
            fzf-vim
            nerdtree
            nvchad
            nvchad-ui
            nvim-treesitter-refactor
            nvim-treesitter.withAllGrammars
            unicode-vim
            vim-cpp-enhanced-highlight
            vim-tmux
            vim-tmux-navigator
          ];
        };
      };
    };

    tmux = {
      enable = true;
      plugins = with pkgs.tmuxPlugins; [
        nord
        vim-tmux-navigator
        sensible
        yank
      ];
    };

    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        acl
        attr
        bzip2
        curl
        glib
        libglvnd
        libmysqlclient
        libsodium
        libssh
        libxml2
        openssl
        stdenv.cc.cc
        systemd
        util-linux
        xz
        zlib
        zstd
      ];
    };
  };

  systemd.watchdog = {
    enable = true;
    device = "/dev/watchdog";
    runTime = "30s";
    rebootTime = "5m";
  };

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      keep-outputs = true;
      builders-use-substitutes = true;
      connect-timeout = 20;
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-oder-than 14d";
    };

    diff-system = true;
  };

  system = {
    autoUpgrade = {
      enable = true;
      randomizedDelaySec = "1h";
      persistent = true;
      system.autoUpgrade.flake = "github:RAD-Development/nix-dotfiles";
    };

    stateVersion = "22.11";
  };
}