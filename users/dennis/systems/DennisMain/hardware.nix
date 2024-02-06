{
  config,
  lib,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  networking.useDHCP = lib.mkDefault true;
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  swapDevices = [{device = "/dev/disk/by-id/nvme-Samsung_SSD_980_PRO_1TB_S5GXNF0W178262L-part4";}];
  boot = {
    kernelModules = ["kvm-amd"];
    extraModulePackages = [];
    initrd = {
      kernelModules = [];
      availableKernelModules = [
        "ahci"
        "nvme"
        "sd_mod"
        "usbhid"
        "xhci_pci"
      ];
    };
  };

  fileSystems = {
    "/" = {
      device = "proot/nixos/root";
      fsType = "zfs";
    };

    "/boot" = {
      device = "pboot/nixos/root";
      fsType = "zfs";
    };

    "/home" = {
      device = "proot/nixos/home";
      fsType = "zfs";
    };

    "/var/lib" = {
      device = "proot/nixos/var/lib";
      fsType = "zfs";
    };

    "/var/log" = {
      device = "proot/nixos/var/log";
      fsType = "zfs";
    };

    "/boot/efis/nvme-Samsung_SSD_980_PRO_1TB_S5GXNF0W178262L-part1" = {
      device = "/dev/disk/by-id/nvme-Samsung_SSD_980_PRO_1TB_S5GXNF0W178262L-part1";
      fsType = "vfat";
    };

    "/media/archive1" = {
      device = "parchive/data";
      fsType = "zfs";
    };

    "/media/archive2" = {
      device = "parchive2/data";
      fsType = "zfs";
    };
  };
}
