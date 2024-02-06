{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Desktop programs
    firefox

    # Python packages
    python312

    nano
    htop
  ];
}
