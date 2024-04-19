{ lib, ... }:
{
  services.autopull = {
    enable = lib.mkDefault true;
    ssh-key = lib.mkDefau "/root/.ssh/id_ed25519_ghdeploy";
    path = lib.mkDefau /root/dotfiles;
  };

  system.autoUpgrade = {
    enable = lib.mkDefault true;
    flags = [ "--accept-flake-config" ];
    randomizedDelaySec = "1h";
    persistent = true;
    flake = "github:RAD-Development/nix-dotfiles";
  };
}
