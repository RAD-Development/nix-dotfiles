{ lib, modulesPath, ... }:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  networking.useDHCP = lib.mkDefault true;
  boot = {
    kernelModules = [ ];
    extraModulePackages = [ ];
    initrd = {
      kernelModules = [ ];
      availableKernelModules = [
        "ahci"
        "nvme"
        "sd_mod"
        "usbhid"
        "xhci_pci"
      ];
    };
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
  };
}
