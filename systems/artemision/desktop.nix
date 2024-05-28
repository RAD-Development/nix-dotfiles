{ pkgs, ... }:

{
  # installs hyprland, and its dependencies

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  # Optional, hint electron apps to use wayland:
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  services = {
    xserver = {
      enable = true;
      displayManager.session = [
        {
          manage = "desktop";
          name = "hyprland";
          start = ''
            bash ${./hypr/wrappedhl} &
            waitPID=$!
          '';
        }
      ];
      displayManager.gdm = {
        enable = true;
        wayland = true;
      };
    };

    dbus = {
      enable = true;
      implementation = "broker";
    };
  };

  programs.gnupg.agent = {
    enable = true;
    #pinentryPackage = pkgs.pinentry-rofi;
    pinentryPackage = pkgs.pinentry-gnome3;
    #settings = {
    #  keyserver-options = "auto-key-retrieve";
    #  auto-key-locate = "hkps://keys.openpgp.org";
    #  keyserver = "hkps://keys.openpgp.org";
    #keyserver  =  "hkp://pgp.mit.edu";
    # "na.pool.sks-keyservers.net"
    # "ipv4.pool.sks-keyservers.net"
    # "p80.pool.sks-keyservers.net"
    # ];
    #};
  };

  environment.systemPackages = with pkgs; [
    libsForQt5.qt5.qtwayland
    qt6.qtwayland
  ];
}
