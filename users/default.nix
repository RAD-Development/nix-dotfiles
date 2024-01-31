{ lib
, config
, pkgs
, name
, publicKeys ? [ ]
, defaultShell ? "zsh"
,
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
  shell = lib.mkIf config.programs.${defaultShell}.enable pkgs.${defaultShell};
  hashedPasswordFile = config.sops.secrets."${name}/user-password".path or null;
  openssh.authorizedKeys.keys = publicKeys;
}
