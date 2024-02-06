{pkgs, ...}: {
  imports = [
    ../configuration.nix
    ./program.nix
    ../program.nix
  ];

  c3d2.audioStreaming = true;
  networking = {
    hostId = "a298ad87";
    networkmanager.enable = true;
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    initrd = {
      kernelModules = ["amdgpu"];
      luks.devices."cryptroot".device = "/dev/disk/by-uuid/4964c656-c64a-490a-a181-ec348874bd7f";
    };
  };

  hardware = {
    sensor.iio.enable = true;
    opengl = {
      enable = true;
      driSupport = true;
      extraPackages = with pkgs; [
        rocmPackages.clr
        rocmPackages.clr.icd
      ];
    };
  };

  programs = {
    hyprland.enable = true;
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };

    zsh.shellAliases = {
      nixedit = "nvim ~/dotfiles/users/dennis/systems/DennisLaptop/configuration.nix";
      nixeditp = "nvim ~/dotfiles/users/dennis/systems/DennisLaptop/program.nix";
      nixedith = "nvim ~/dotfiles/users/dennis/systems/DennisLaptop/hardware-configuration.nix";
    };
  };

  services = {
    printing.enable = true;
    xserver.videoDrivers = ["amdgpu"];
    udev = {
      extraRules = "SUBSYSTEM==\"usb\", ATTRS{idVendor}==\"03e7\", MODE=\"0666\"\n";
      extraHwdb = ''
        sensor:modalias:acpi:INVN6500*:dmi:*svn*ASUSTeK*:*pn*TP300LA*
        ACCEL_MOUNT_MATRIX=0, 1, 0; 1, 0, 0; 0, 0, 1
      '';
    };
  };

  environment.sessionVariables = {
    KICAD7_SYMBOL_DIR = "/home/dennis/repos/turag/elektronik/KiCad/kicad-symbols";
    KICAD7_FOOTPRINT_DIR = "/home/dennis/repos/turag/elektronik/KiCad/kicad-footprints";
    KICAD7_3DMODEL_DIR = "/home/dennis/repos/turag/elektronik/KiCad/kicad-packages3D";
  };
}
