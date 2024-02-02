{ pkgs, config, ... }:
{
  imports = [
    ./banner.nix
  ];

  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.utf8";
  networking.firewall.allowedTCPPorts = [ 22 ];
  boot.plymouth.enable = true;

  services = {
    udev.packages = with pkgs; [
      yubikey-personalization
    ];

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      wireplumber.enable = true;
    };

    openssh = {
      enable = true;
      extraConfig = ''StreamLocalBindUnlink yes'';
      authorizedKeysFiles = [ "../yubikey.pub" ];
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };

    xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
      xkb.layout = "de";
    };

    kmscon = {
      enable = true;
      extraOptions = "--xkb-layout ${config.services.xserver.xkb.layout}";
    };
  };

  environment.shellInit = ''
    gpg-connect-agent /bye
    export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
  '';

  security = {
    rtkit.enable = true;
    pam.yubico = {
      enable = true;
      mode = "challenge-response";
      control = "sufficient";
      id = [ "22928767" ];
    };
  };

  fonts.fontDir.enable = true;
  console.keyMap = "de";
  nixpkgs.config.allowUnfree = true;

  sound = {
    enable = true;
    mediaKeys.enable = true;
  };

  hardware = {
    pulseaudio.enable = false;
  };

  programs = {
    nix-index-database.comma.enable = true;
    command-not-found.enable = false;
    fzf.keybindings = true;
    ssh.startAgent = false;
    git = {
      enable = true;
      lfs.enable = true;
      config = {
        interactive.singlekey = true;
        pull.rebase = true;
        rebase.autoStash = true;
        safe.directory = "/etc/nixos";
        alias = {
          p = "pull";
          r = "reset --hard";
          ci = "commit";
          co = "checkout";
          lg = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)'";
          st = "status";
          undo = "reset --soft HEAD^";
        };
      };
    };

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    zsh = {
      enable = true;
      syntaxHighlighting.enable = true;
      zsh-autoenv.enable = true;
      enableCompletion = true;
      enableBashCompletion = true;
      autosuggestions = {
        enable = true;
        strategy = [ "completion" ];
        async = true;
      };

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

      promptInit = ''
        command_not_found_handler() {
          local command="$1"
          local parameters=("$\{(@)argv[2, -1]}")
          comma "$command" "$parameters"
        }
      '';
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

        packages.myVimPackage.start = with pkgs.vimPlugins; [
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

    tmux = {
      enable = true;
      keyMode = "vi";
      terminal = "screen-256color\"\nset -g mouse on\n# \"";
      shortcut = "Space";
      baseIndex = 1;
      clock24 = true;
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

  i18n.supportedLocales = [
    "en_US.UTF-8/UTF-8"
    "de_DE.UTF-8/UTF-8"
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "adobe-reader-9.5.5"
    "electron-12.2.3"
    "electron-19.1.9"
  ];

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      keep-outputs = true;
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  environment.gnome.excludePackages = (with pkgs; [
    gnome-photos
    gnome-tour
    gedit
  ]) ++ (with pkgs.gnome; [
    cheese # webcam tool
    gnome-contacts
    gnome-music
    gnome-weather
    gnome-maps
    gnome-terminal
    simple-scan # document scanner
    epiphany # web browser
    geary # email reader
    evince # document viewer
    gnome-characters
    totem # video player
    tali # poker game
    iagno # go game
    hitori # sudoku game
    atomix # puzzle game
  ]);

  system.stateVersion = "22.11";
}
