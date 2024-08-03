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
    proxychains
    sweet-nova
    util-linux
    vlc
    zoom-us
  ];
}
