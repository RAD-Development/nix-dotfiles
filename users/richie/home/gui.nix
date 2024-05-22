{ pkgs, ... }:
{
  imports = [ ./vscode ];

  home.packages = with pkgs; [
    beeper
    candy-icons
    cinnamon.nemo
    cinnamon.nemo-fileroller
    discord-canary
    firefox
    gimp
    obs-studio
    obsidian
    sweet-nova
  ];
}
