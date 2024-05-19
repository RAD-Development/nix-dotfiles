{ lib, ... }:
{
  services.autopull = {
    enable = lib.mkDefault true;
    repo.dotfiles = {
      enable = lib.mkDefault true;
      ssh-key = lib.mkDefault "/root/.ssh/id_ed25519_ghdeploy";
      path = lib.mkDefault /root/dotfiles;
    };
  };

  system.autoUpgrade = {
    enable = lib.mkDefault true;
    flags = [ "--accept-flake-config" ];
    randomizedDelaySec = "1h";
    persistent = true;
    flake = "github:RAD-Development/nix-dotfiles";
  };
}
