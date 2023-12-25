{ pkgs, ... }:
{
  i18n = {
    defaultLocale = "en_US.utf8";
    supportedLocales = [ "en_US.UTF-8/UTF-8" ];
  };

  boot = {
    default = true;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
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

  nixpkgs.config.allowUnfree = true;

  programs = {
    fzf.keybindings = true;

    git = {
      enable = true;
      config = {
        interactive.singlekey = true;
        pull.rebase = true;
        rebase.autoStash = true;
        safe.directory = "/etc/nixos";
      };
    };

    neovim = {
      enable = true;
      defaultEditor = true;
      configure = {
        customRC = ''
            set undofile         " save undo file after quit
            set undolevels=1000  " number of steps to save
            set undoreload=10000 " number of lines to save

            " Save Cursor Position
            au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
          '';
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
      };
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
    device = "/dev/watchdog";
    runtimeTime = "30s";
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
      options = "--delete-oder-than 30d";
    };

    diffSystem = true;
  };

  system = {
    autoUpgrade = {
      enable = true;
      randomizedDelaySec = "1h";
      persistent = true;
      flake = "github:RAD-Development/nix-dotfiles";
    };
  };
}