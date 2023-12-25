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
      amdGPU = libS.mkOpinionatedOption "the system contains a AMD GPU";
    };
  };

  config.boot = lib.mkIf cfg.default {
    initrd = {
      # networking for netcard kernelModules = [ "e1000e" ];
      kernelModules = lib.mkIf cfg.amdGPU [ "amdgpu" ];

      network.enable = true;
      network.ssh = {
        enable = true;
        hostKeys = [
          "/root/ssh_key"
        ];
        port = 2222;
      };
      luks = {
        devices."cryptroot" = {
          device = "/dev/sda1";
          preLVM = true;
        };
      };
    };

    supportedFilesystems = [ "zfs" ];
    tmp.useTmpfs = true;
    kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
    kernelParams = [
      "ip=<ip-addr>::<ip-gateway>:<netmask>"
      "nordrand"
    ] ++ lib.optional (cfg.cpuType == "amd") "kvm-amd";

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
        enableCryptodisk = true;
      };
    };
  };
}