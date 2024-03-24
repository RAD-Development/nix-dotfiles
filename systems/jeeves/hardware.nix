# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [
    "mpt3sas"
    "nvme"
    "xhci_pci"
    "ahci"
    "uas"
    "usb_storage"
    "usbhid"
    "sd_mod"
    "sr_mod"
  ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/0f78fa87-30be-4173-b0fa-eaa956cf83aa";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/BB77-2647";
    fsType = "vfat";
  };

  swapDevices = [ { device = "/dev/disk/by-uuid/4c797a94-be32-43d3-89ac-7f02912c7cf5"; } ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp38s0f3u2u2c2.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp97s0f0np0.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp97s0f1np1.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp98s0f0.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp98s0f1.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
