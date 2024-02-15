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
  swapDevices = [{device = "/dev/disk/by-uuid/9d4ef549-d426-489d-8332-0a49589c6aed";}];
  boot = {
    kernelModules = ["kvm-amd"];
    extraModulePackages = [];
    initrd = {
      kernelModules = [];
      availableKernelModules = ["xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod"];
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/c59f7261-ebab-4cc9-8f1d-3f4c2e4b1971";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/7295-A442";
      fsType = "vfat";
    };
  };
}
