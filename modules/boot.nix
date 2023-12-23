{ config, lib, ... }:

let
  cfg = config.boot;
in
{
  options = {
    boot = {
      default = lib.mkOpinionatedOption "enable the boot builder";
    };
  };

  cfg = lib.mkIf cfg.default {
    supportedFilesystems = [ "zfs" ];
    tmp.useTmpfs = true;
    kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
    kernelParams = [ "kvm-amd" "nordrand" ];
    zfs = {            
      enableUnstable = true;
      devNodes = "/dev/disk/by-id/";
      forceImportRoot = true;
    };
    loader = {
      efi = {
        canTouchEfiVariables = false;
        efiSysMountPoint = "/boot/efis/nvme-Samsung_SSD_980_PRO_1TB_S5GXNF0W178262L-part1";
      };
      generationsDir.copyKernels = true;
      grub = {
        enable = true;
        copyKernels = true;
        zfsSupport = true;
        efiSupport = true;
        efiInstallAsRemovable = true;
        fsIdentifier = "uuid";
        device = "nodev";
        extraInstallCommands = "[ ! -e /boot/efis/nvme-Samsung_SSD_980_PRO_1TB_S5GXNF0W178262L-part1/EFI ] || cp -r /boot/efis/nvme-Samsung_SSD_980_PRO_1TB_S5GXNF0W178262L-part1/EFI/* /boot/efis/nvme-Samsung_SSD_980_PRO_1TB_S5GXNF0W178262L-part1";
      };
    };
  };
}