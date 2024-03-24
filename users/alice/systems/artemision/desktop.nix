{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  # Optional, hint electron apps to use wayland:
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  services.xserver.displayManager.gdm = {
    enable = true;
  };
}
