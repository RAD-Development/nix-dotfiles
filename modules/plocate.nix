{ lib, pkgs, ... }:

{
  services.locate = {
    enable = lib.mkDefault true;
    localuser = lib.mkDefault null;
    package = lib.mkDefault pkgs.plocate;
  };
}
