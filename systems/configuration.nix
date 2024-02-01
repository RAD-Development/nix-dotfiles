{ lib, pkgs, config, ... }: {
  i18n = {
    defaultLocale = "en_US.utf8";
    supportedLocales = [ "en_US.UTF-8/UTF-8" ];
  };

  boot = {
    default = true;
    kernel.sysctl = { "net.ipv6.conf.ens3.accept_ra" = 1; };
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  users.defaultUserShell = pkgs.zsh;

  networking = {
    firewall = {
      enable = lib.mkDefault true;
      allowedTCPPorts = [ ];
    };
  };

  security.auditd.enable = true;

  services = {
    fail2ban = {
      enable = lib.mkIf config.networking.firewall.enable (lib.mkDefault true);
      recommendedDefaults = true;
    };

    openssh = {
      enable = true;
      fixPermissions = true;
      extraConfig = "StreamLocalBindUnlink yes";

      hostKeys = [
        {
          bits = 4096;
          path = "/etc/ssh/ssh_host_rsa_key";
          type = "rsa";
        }
        {
          path = "/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
        {
          path = "/etc/ssh/ssh_host_ecdsa_key";
          type = "ecdsa";
        }
      ];

      # all of these setting are recommended by lynis unless otherwise commented
      settings = {
        AllowAgentForwarding = "no";
        AllowTcpForwarding = "no";
        ChallengeResponseAuthentication = "no";
        ClientAliveCountMax = lib.mkDefault 2;
        Compression = "NO";
        IgnoreRhosts = "yes";
        LogLevel = lib.mkDefault "VERBOSE";
        MaxAuthTries = 3;
        MaxSessions = lib.mkDefault 2;
        PasswordAuthentication = false;
        PermitEmptyPasswords = "no";
        PermitRootLogin = "no";
        TcpKeepAlive = "no";
        X11Forwarding = lib.mkDefault false;

        KexAlgorithms = [ "curve25519-sha256@libssh.org" "diffie-hellman-group-exchange-sha256" ];

        Ciphers = [ "chacha20-poly1305@openssh.com" "aes256-gcm@openssh.com" "aes128-gcm@openssh.com" "aes256-ctr" "aes192-ctr" "aes128-ctr" ];

        Macs = [ "hmac-sha2-512-etm@openssh.com" "hmac-sha2-256-etm@openssh.com" "umac-128-etm@openssh.com" "hmac-sha2-512" "hmac-sha2-256" "umac-128@openssh.com" ];
      };
    };
    autopull = {
      enable = true;
      path = /root/dotfiles;
      ssh-key = "/root/.ssh/id_ed25519_ghdeploy";
    };
  };

  nixpkgs.config.allowUnfree = true;

  programs = {
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
      ohMyZsh = { enable = true; };
    };

    nix-ld = {
      enable = true;
      libraries = with pkgs; [ acl attr bzip2 curl glib libglvnd libmysqlclient libsodium libssh libxml2 openssl stdenv.cc.cc systemd util-linux xz zlib zstd ];
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
      options = "--delete-older-than 30d";
    };

    diffSystem = true;
  };

  system = {
    autoUpgrade = {
      enable = true;
      randomizedDelaySec = "1h";
      persistent = true;
      # Running this since this is private right now.
      # Need to set up a ssh-key for github for autoUpgrade
      flake = "git+ssh://git@github.com/RAD-Development/nix-dotfiles";
    };
  };
}
