{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ filebot ];
}
