{ lib, config, pkgs, userName, pubKeys }:
{
  isNormalUser = true;
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
  shell = pkgs.zsh;
  openssh.authorizedKeys.keys = [
    (lib.mkIf (pubKeys ? ${config.networking.hostName}) pubKeys.${config.networking.hostName})
  ];
}