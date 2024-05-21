{ ... }:

{
  programs.waybar = {
    enable = true;
    #settings = builtins.fromJSON (import ./waybar.json);
  };
}
