{ pkgs, ... }:
{
  imports = [
    ./vscode
    ./firefox.nix
  ];

  home.packages = with pkgs; [
    beeper
    candy-icons
    cinnamon.nemo
    cinnamon.nemo-fileroller
    discord-canary
    firefox
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
