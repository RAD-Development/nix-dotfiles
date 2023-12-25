{
  lib,
  config,
  pkgs,
  name,
  publicKeys ? [],
  defaultShell ? "zsh",
}:

{
  inherit name;
  isNormalUser = true;
  extraGroups = [
    "wheel"
    "media"
    (lib.mkIf config.networking.networkmanager.enable "networkmanager")
    (lib.mkIf config.programs.adb.enable "adbusers")
    (lib.mkIf config.programs.wireshark.enable "wireshark")
    (lib.mkIf config.virtualisation.docker.enable "docker")
    "libvirtd"
    "dialout"
    "plugdev"
    "uaccess"
  ];
  shell = pkgs.${defaultShell};
  openssh.authorizedKeys.keys = publicKeys;
}