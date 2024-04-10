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

  system = {
    autoUpgrade = {
      enable = true;
      randomizedDelaySec = "1h";
      persistent = true;
      flake = "github:RAD-Development/nix-dotfiles";
    };
  };
}
