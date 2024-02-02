# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot = {
    initrd = {
      availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "sd_mod" ];
      kernelModules = [ ];
    };
    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
  };

  fileSystems."/" =
    {
      device = "proot/nixos/root";
      fsType = "zfs";
    };


  fileSystems."/boot" =
    {
      device = "pboot/nixos/root";
      fsType = "zfs";
    };

  fileSystems."/home" =
    {
      device = "proot/nixos/home";
      fsType = "zfs";
    };

  fileSystems."/var/lib" =
    {
      device = "proot/nixos/var/lib";
      fsType = "zfs";
    };

  fileSystems."/var/log" =
    {
      device = "proot/nixos/var/log";
      fsType = "zfs";
    };

  fileSystems."/boot/efis/nvme-Samsung_SSD_980_PRO_1TB_S5GXNF0W178262L-part1" =
    {
      device = "/dev/disk/by-id/nvme-Samsung_SSD_980_PRO_1TB_S5GXNF0W178262L-part1";
      fsType = "vfat";
    };

  fileSystems."/media/archive1" = {
    device = "parchive/data";
    fsType = "zfs";
  };

  fileSystems."/media/archive2" = {
    device = "parchive2/data";
    fsType = "zfs";
  };

  swapDevices = [{ device = "/dev/disk/by-id/nvme-Samsung_SSD_980_PRO_1TB_S5GXNF0W178262L-part4"; }];
  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
