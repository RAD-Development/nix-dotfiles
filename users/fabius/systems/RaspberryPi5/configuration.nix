{ pkgs, lib, ... }:
{
  imports = [
    ./program.nix
  ];

  programs.command-not-found.enable = false;
  nixpkgs.config.allowUnfree = true;
  sound.enable = true;
  networking.hostId = "85d24791";
  services.udev.enable = false;
  boot = {
    supportedFilesystems = [ "zfs" ];
    tmp.useTmpfs = true;
    kernelPackages = pkgs.linuxPackages_rpi4;
    loader.grub.enable = lib.mkForce false;
  };

  hardware = {
    opengl.enable = true;
    opengl.driSupport = true;
  };

  system.stateVersion = "23.11";
}
