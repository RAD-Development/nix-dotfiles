{ config, lib, ... }:
{
  imports = [
    ../configuration.nix
    ./program.nix
    ../program.nix
  ];

  virtualisation.libvirtd.enable = true;
  networking = {
    hostId = "3457acd3";
    networkmanager.enable = true;
  };

  boot = {
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
      generationsDir.copyKernels = true;
      efi = {
        canTouchEfiVariables = false;
        efiSysMountPoint = "/boot/efis/nvme-Samsung_SSD_980_PRO_1TB_S5GXNF0W178262L-part1";
      };

      grub = {
        enable = lib.mkForce true;
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

  fileSystems = {
    "/".options = [ "X-mount.mkdir" "noatime" ];
    "/boot".options = [ "X-mount.mkdir" "noatime" ];
    "/home".options = [ "X-mount.mkdir" "noatime" ];
    "/var/lib".options = [ "X-mount.mkdir" "noatime" ];
    "/var/log".options = [ "X-mount.mkdir" "noatime" ];
    "/boot/efis/nvme-Samsung_SSD_980_PRO_1TB_S5GXNF0W178262L-part1".options = [ "x-systemd.idle_timeout=1min" "x-systemd.automount" "nomount" "nofail" "noatime" "X-mount.mkdir" ];
  };

  sound = {
    enable = true;
    mediaKeys.enable = true;
  };

  hardware = {
    enableAllFirmware = true;
    pulseaudio.enable = false;
    opengl.enable = true;
    opengl.driSupport = true;
    nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      modesetting.enable = true;
      powerManagement.enable = true;
    };
  };

  programs = {
    dconf.enable = true;
    droidcam.enable = true;
    zsh.shellAliases = {
      nixedit = "nvim ~/dotfiles/users/dennis/systems/DennisMain/configuration.nix";
      nixeditp = "nvim ~/dotfiles/users/dennis/systems/DennisMain/program.nix";
      nixedith = "nvim ~/dotfiles/users/dennis/systems/DennisMain/hardware-configuration.nix";
    };
  };

  services = {
    xserver.videoDrivers = [ "nvidia" ];
    udev.extraRules = "SUBSYSTEM==\"usb\", ATTRS{idVendor}==\"03e7\", MODE=\"0666\"\n";
    printing.enable = true;
    avahi = {
      enable = true;
      nssmdns4 = true;
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };

  system.stateVersion = "23.05";
}
