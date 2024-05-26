{ lib, pkgs, ... }:

{
  services.locate = {
    enable = lib.mkDefault true;
    package = lib.mkDefault pkgs.plocate;
  };
}
