{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Adds some items from the server config without importing everything
  security.auditd.enable = true;
  nixpkgs.config.allowUnfree = true;

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

  users = {
    defaultUserShell = pkgs.zsh;
    mutableUsers = false;
  };

  networking = {
    firewall = {
      enable = lib.mkDefault true;
      allowedTCPPorts = [ ];
    };
  };

  services = {
    autopull = {
      enable = true;
      ssh-key = "/root/.ssh/id_ed25519_ghdeploy";
      path = /root/dotfiles;
    };
  };

  # programs = {
  #   zsh = {
  #     enable = true;
  #     syntaxHighlighting.enable = true;
  #     zsh-autoenv.enable = true;
  #     enableCompletion = true;
  #     enableBashCompletion = true;
  #     ohMyZsh.enable = true;
  #     autosuggestions = {
  #       enable = true;
  #       strategy = [ "completion" ];
  #       async = true;
  #     };
  #   };
  # };

  nix = {
    diffSystem = true;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      keep-outputs = true;
      builders-use-substitutes = true;
      connect-timeout = 20;
    };

    # free up to 10 gb when only 1 gb left
    extraOptions = ''
      min-free = ${toString (1 * 1024 * 1024 * 1024)}
      max-free = ${toString (10 * 1024 * 1024 * 1024)}
    '';

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    optimise = {
      automatic = true;
      dates = [ "01:00" ];
    };
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
