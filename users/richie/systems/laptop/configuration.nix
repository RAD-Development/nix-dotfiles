{ config, pkgs, ... }:

{
  imports = [
    ../programs.nix
    ./hardware-configuration.nix
  ];
  nixpkgs.config.allowUnfree = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostName = "laptop";
    networkmanager.enable = true;
    wireless.enable = true;
  };


  time.timeZone = "America/New_York";

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services = {
    xserver.enable = true;

    xserver.displayManager.sddm.enable = true;
    xserver.desktopManager.plasma5.enable = true;

    xserver = {
      layout = "us";
      xkbVariant = "";
    };

    printing.enable = true;

    sound.enable = true;
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };

  users.users.richie = {
    isNormalUser = true;
    description = "richie";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      firefox
      kate
    ];
  };

  system.stateVersion = "23.11";
}
