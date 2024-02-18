{ config, lib, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  networking.useDHCP = lib.mkDefault true;
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  swapDevices = [{ device = "/dev/disk/by-uuid/89c28811-5cc0-4657-af8f-deefd8427585"; }];
  boot = {
    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
    initrd.kernelModules = [ ];
    initrd.availableKernelModules = [
      "nvme"
      "rtsx_pci_sdmmc"
      "sd_mod"
      "usb_storage"
      "xhci_pci"
    ];
  };

  fileSystems = {
    "/" = {
      device = "zroot/ROOT/default";
      fsType = "zfs";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/94E9-A98F";
      fsType = "vfat";
    };

    "/var/lib" = {
      device = "zroot/var/lib";
      fsType = "zfs";
    };

    "/var/log" = {
      device = "zroot/var/log";
      fsType = "zfs";
    };

    "/nix" = {
      device = "zroot/nix";
      fsType = "zfs";
    };

    "/home" = {
      device = "zroot/home";
      fsType = "zfs";
    };

    "home/dennis" = {
      device = "zroot/home/dennis";
      fsType = "zfs";
    };
  };
}


