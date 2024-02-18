{ pkgs, config, ... }:
{
  imports = [
    ./banner.nix
  ];

  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.utf8";
  boot.plymouth.enable = true;
  fonts.fontDir.enable = true;
  console.keyMap = "de";
  hardware.pulseaudio.enable = false;
  networking = {
    nftables.enable = true;
    firewall.allowedTCPPorts = [ 22 ];
  };

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

  sound = {
    enable = true;
    mediaKeys.enable = true;
  };

  programs = {
    nix-index-database.comma.enable = true;
    command-not-found.enable = false;
    fzf.keybindings = true;
    ssh.startAgent = false;
    git = {
      enable = true;
      lfs.enable = true;
    };

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    zsh.promptInit = ''
      command_not_found_handler() {
        local command="$1"
        local parameters=("$\{(@)argv[2, -1]}")
        comma "$command" "$parameters"
      }
    '';

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

  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      "electron-19.1.9"
    ];
  };

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
}
