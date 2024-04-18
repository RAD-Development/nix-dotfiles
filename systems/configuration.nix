{ lib, ... }:
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

  services.autopull = {
    enable = true;
    ssh-key = "/root/.ssh/id_ed25519_ghdeploy";
    path = /root/dotfiles;
  };

  system.autoUpgrade = {
    enable = true;
    flags = [ "--accept-flake-config" ];
    randomizedDelaySec = "1h";
    persistent = true;
    flake = "github:RAD-Development/nix-dotfiles";
  };
}
