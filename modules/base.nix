{ lib, ... }:
{
  nixpkgs.config.allowUnfree = lib.mkDefault  true;

  users = {
    mutableUsers = lib.mkDefault false;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };
}
