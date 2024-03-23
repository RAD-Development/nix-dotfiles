# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/f3c11d62-37f4-495e-b668-1ff49e0d3a47";
      fsType = "ext4";
      options = [ "noatime" "nodiratime" "discard" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/720af942-464c-4c1e-be41-0438936264f0";
      fsType = "ext4";
      options = [ "noatime" "nodiratime" "discard" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/035f23f8-d895-4b0c-bcf5-45885a5dbbd9";
      fsType = "ext4";
      options = [ "noatime" "nodiratime" "discard" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/7f0dba0f-d04e-4c94-9fba-1d0811673df1"; }
    ];

  boot.initrd.luks.devices = 	
    { "nixos-pv" ={ 
      device = "/dev/disk/by-uuid/12a7f660-bbcc-4066-81d0-e66005ee534a";
      preLVM = true;
      allowDiscards = true;
    };}
  ;


  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp196s0f3u2u1.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp4s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
