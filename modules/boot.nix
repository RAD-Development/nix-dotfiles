{ config, lib, libS, ... }:

let
  cfg = config.boot;
in
{
  options = {
    boot = {
      default = libS.mkOpinionatedOption "enable the boot builder";
    };
  };

  config.boot = lib.mkIf cfg.default {
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
      };
    };
  };
}