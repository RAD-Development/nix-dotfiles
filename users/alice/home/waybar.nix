{ lib, machineConfig, ... }:
lib.mkIf (!machineConfig.server) {
  programs.waybar = {
    enable = true;
    #settings = builtins.fromJSON (import ./waybar.json);
  };
}
