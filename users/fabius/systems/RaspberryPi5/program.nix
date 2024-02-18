{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Desktop programs
    firefox
    nano
    htop
  ];
}
