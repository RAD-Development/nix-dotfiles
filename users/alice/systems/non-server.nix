{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Adds some items from the server config without importing everything
  security.auditd.enable = true;

  i18n = {
    defaultLocale = "en_US.utf8";
    supportedLocales = [ "en_US.UTF-8/UTF-8" ];
  };

  boot = {
    default = true;
  };

  users = {
    defaultUserShell = pkgs.zsh;
  };

  networking = {
    firewall = {
      enable = lib.mkDefault true;
      allowedTCPPorts = [ ];
    };
  };

  services.openssh.enable = false;
  services.autopull = {
    enable = false;
    ssh-key = "/root/.ssh/id_ed25519_ghdeploy";
    path = /root/dotfiles;
  };

  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    zsh-autoenv.enable = true;
    enableCompletion = true;
    enableBashCompletion = true;
    ohMyZsh.enable = true;
    autosuggestions = {
      enable = true;
      strategy = [ "completion" ];
      async = true;
    };
  };
}
