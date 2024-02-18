{ lib, modulesPath, ... }:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  networking.useDHCP = lib.mkDefault true;
  swapDevices = [ { device = "/dev/disk/by-uuid/491bd391-022d-41ee-b85b-a08d23fe6982"; } ];
  boot = {
    kernelModules = [ ];
    extraModulePackages = [ ];
    initrd = {
      kernelModules = [ ];
      availableKernelModules = [
        "ata_piix"
        "sd_mod"
        "sr_mod"
        "uhci_hcd"
        "virtio_pci"
        "virtio_scsi"
      ];
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/b7d56fcd-1bcc-4d74-bdd5-b85d47c06584";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/0904-D3DB";
      fsType = "vfat";
    };
  };
}
