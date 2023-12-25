{ config, lib, libS, ... }:

let
  cfg = config.boot;
in
{
  options = {
    boot = {
      default = libS.mkOpinionatedOption "enable the boot builder";
      cpuType = lib.mkOption {
        type = lib.types.str;
        example = "amd";
        default = "";
        description = "The cpu-type installed on the server.";
      };
    };
  };

  config.boot = lib.mkIf cfg.default {
    supportedFilesystems = [ "zfs" ];
    tmp.useTmpfs = true;
    kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
    kernelParams = [ "nordrand" ] ++ lib.optional (cfg.cpuType == "amd") "kvm-amd";
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