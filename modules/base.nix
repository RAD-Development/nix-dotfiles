{ lib, ... }:
{
  nixpkgs.config.allowUnfree = lib.mkDefault true;

  programs = {
    zsh.enable = true;
    fish.enable = true;
    bash.enable = true;
  }

  users = {
    mutableUsers = lib.mkDefault false;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };
}
