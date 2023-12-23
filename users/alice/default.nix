{
  pkgs,
  lib,
  config,
}: let
  pubKeys = import ./keys/default.nix;
in {
  isNormalUser = true;
  description = "AmethystAndroid";
  uid = 1000;
  extraGroups = [
    "wheel"
    "media"
    (lib.mkIf config.networking.networkmanager.enable "networkmanager")
    (lib.mkIf config.programs.adb.enable "adbusers")
    (lib.mkIf config.programs.wireshark.enable "wireshark")
    (lib.mkIf config.programs.virtualisation.docker.enable "docker")
    "libvirtd"
    "dialout"
    "plugdev"
    "uaccess"
  ];
  shell = pkgs.fish;
  openssh.authorizedKeys.keys = [
    (lib.mkIf (pubKeys ? ${config.networking.hostName}) pubKeys.${config.networking.hostName})
  ];
}