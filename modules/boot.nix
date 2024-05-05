{
  config,
  lib,
  libS,
  ...
}:

let
  cfg = config.boot;
in
{
  options = {
    boot = {
      default = libS.mkOpinionatedOption "enable the boot builder";
      fullDiskEncryption = libS.mkOpinionatedOption "use luks full disk encryption";
      useSystemdBoot = libS.mkOpinionatedOption "use systemd boot";
      cpuType = lib.mkOption {
        type = lib.types.str;
        example = "amd";
        default = "";
        description = "The cpu-type installed on the server.";
      };

      amdGPU = libS.mkOpinionatedOption "the system contains a AMD GPU";
      filesystem = lib.mkOption {
        type = lib.types.str;
        example = "btrfs";
        default = "ext4";
        description = "The filesystem installed.";
      };
    };
  };

  config.boot = lib.mkIf cfg.default {
    supportedFilesystems = [ cfg.filesystem ];
    tmp.useTmpfs = true;
    kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
    kernelParams =
      [ "nordrand" ]
      ++ lib.optional (cfg.cpuType == "amd") "kvm-amd"
      ++ lib.optional cfg.fullDiskEncryption "ip=<ip-addr>::<ip-gateway>:<netmask>";
    initrd = {
      kernelModules = lib.mkIf cfg.amdGPU [ "amdgpu" ];
      network = lib.mkIf cfg.fullDiskEncryption {
        enable = true;
        ssh = {
          enable = true;
          port = 2222;
        };
      };
    };

    zfs = lib.mkIf (cfg.filesystem == "zfs") {
      devNodes = "/dev/disk/by-id/";
      forceImportRoot = true;
    };

    loader = {
      efi.canTouchEfiVariables = false;
      generationsDir.copyKernels = true;
      systemd-boot = lib.mkIf cfg.useSystemdBoot {
        enable = true;
        configurationLimit = 10;
      };
      grub = lib.mkIf (!cfg.useSystemdBoot) {
        enable = lib.mkForce true;
        copyKernels = true;
        zfsSupport = lib.mkIf (cfg.filesystem == "zfs") true;
        efiSupport = true;
        efiInstallAsRemovable = true;
        fsIdentifier = "uuid";
        enableCryptodisk = lib.mkIf cfg.fullDiskEncryption true;
      };
    };
  };
}
