{
  imports = [
    ./hardware.nix
    ../../users/richie/global/syncthing_base.nix
    ../../users/richie/global/zerotier.nix
  ];

  boot = {
    useSystemdBoot = true;
    default = true;
  };

  networking = {
    networkmanager.enable = true;
    hostId = "9ab3b18e";
  };

  hardware = {
    pulseaudio.enable = false;
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };

  security.rtkit.enable = true;
  sound.enable = true;

  services = {
    openssh.settings.PermitRootLogin = "yes";

    autopull.enable = false;

    displayManager.sddm.enable = true;

    xserver = {
      enable = true;
      desktopManager.plasma5.enable = true;
      xkb = {
        layout = "us";
        variant = "";
      };
    };

    printing.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };

  system.autoUpgrade.enable = false;

  system.stateVersion = "23.11";
}
