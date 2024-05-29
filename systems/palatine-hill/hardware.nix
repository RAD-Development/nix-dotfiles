{
  config,
  lib,
  modulesPath,
  ...
}:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  swapDevices = [ { device = "/dev/disk/by-uuid/2b01e592-2297-4eb1-854b-17a63f1d4cf6"; } ];
  boot = {
    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
    initrd = {
      kernelModules = [ ];
      availableKernelModules = [
        "ahci"
        "mpt3sas"
        "nvme"
        "sd_mod"
        "usb_storage"
        "usbhid"
        "xhci_pci"
      ];
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/b3b709ce-fe88-4267-be47-bf991a512cbe";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/4CBA-2451";
      fsType = "vfat";
    };
    "/nix" = {
      device = "ZFS-primary/nix";
      fsType = "zfs";
      depends = [ "/crypto/keys" ];
      neededForBoot = true;
      options = [ "noatime" ];
    };
  };
}
