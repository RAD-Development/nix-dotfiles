{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.waybar = {
    enable = true;
    settings = {
      height = 30;
      spacing = 4;
      modules-left = [
        "hyprland/workspaces"
        "hyprland/submap"
      ];
      modules-center = [ "hyprland/window" ];
      modules-right = [
        "mpd"
        "idle_inhibitor"
        "pulseaudio"
        "network"
        "power-profiles-daemon"
        "cpu"
        "memory"
        "temperature"
        "backlight"
        "keyboard-state"
        "hyprland/language"
        "battery"
        "battery#bat2"
        "clock"
        "tray"
      ];
      keyboard-state = {
        "numlock" = true;
        "capslock" = true;
        "format" = "{name} {icon}";
        "format-icons" = {
          "locked" = "";
        };
      };
    };
  };
}
