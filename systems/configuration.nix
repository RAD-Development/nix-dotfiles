{
  lib,
  pkgs,
  config,
  ...
}:
{
  security.auditd.enable = true;

  boot = {
    default = true;
    kernel.sysctl = {
      "net.ipv6.conf.ens3.accept_ra" = 1;
    };
  };

  networking = {
    firewall = {
      enable = lib.mkDefault true;
      allowedTCPPorts = [ ];
    };
  };

  services = {
    fail2ban = {
      enable = lib.mkIf config.networking.firewall.enable (lib.mkDefault true);
      recommendedDefaults = true;
    };

    autopull = {
      enable = true;
      ssh-key = "/root/.ssh/id_ed25519_ghdeploy";
      path = /root/dotfiles;
    };
  };

  programs = {
    git = {
      enable = true;
      lfs.enable = lib.mkDefault true;
      config = {
        interactive.singlekey = true;
        pull.rebase = true;
        rebase.autoStash = true;
        safe.directory = "/etc/nixos";
      };
    };

    zsh = {
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

  system = {
    autoUpgrade = {
      enable = true;
      flags = [ "--accept-flake-config" ];
      randomizedDelaySec = "1h";
      persistent = true;
      flake = "github:RAD-Development/nix-dotfiles";
    };
  };
}
