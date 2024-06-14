{ pkgs, ... }:
{
  imports = [
    ./firefox.nix
    ./vscode
  ];

  home.packages = with pkgs; [
    beeper
    candy-icons
    cinnamon.nemo
    cinnamon.nemo-fileroller
    discord-canary
    gimp
    gparted
    mediainfo
    obs-studio
    obsidian
    sweet-nova
    vlc
    util-linux
  ];
}
