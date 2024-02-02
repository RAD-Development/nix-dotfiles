{ config, lib, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    {
      device = "zroot/ROOT/default";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/94E9-A98F";
      fsType = "vfat";
    };

  fileSystems."/var/lib" =
    {
      device = "zroot/var/lib";
      fsType = "zfs";
    };

  fileSystems."/var/log" =
    {
      device = "zroot/var/log";
      fsType = "zfs";
    };

  fileSystems."/nix" =
    {
      device = "zroot/nix";
      fsType = "zfs";
    };

  fileSystems."/home" =
    {
      device = "zroot/home";
      fsType = "zfs";
    };

  fileSystems."/home/dennis" =
    {
      device = "zroot/home/dennis";
      fsType = "zfs";
    };

  swapDevices = [{ device = "/dev/disk/by-uuid/89c28811-5cc0-4657-af8f-deefd8427585"; }];
  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}


