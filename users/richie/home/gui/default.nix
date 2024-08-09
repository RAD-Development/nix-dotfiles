{ pkgs, ... }:
{
  imports = [
    ./firefox.nix
    ./vscode
  ];

  home.packages = with pkgs; [
    beeper
    candy-icons
    nemo
    nemo-fileroller
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
