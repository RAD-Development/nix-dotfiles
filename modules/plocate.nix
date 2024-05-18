{ lib, pkgs, ... }:

{
  services.locate.enable = lib.mkDefault true;
  environment.systemPackages = [ pkgs.plocate ];
}
