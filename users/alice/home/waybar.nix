{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.waybar = {
    enable = true;
    #settings = builtins.fromJSON (import ./waybar.json);
  };
}
