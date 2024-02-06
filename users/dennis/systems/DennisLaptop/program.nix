{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # Desktop programs
    freecad
    kicad
    krita
    xournalpp

    # Drivers
    iio-sensor-proxy
    rocmPackages.rocminfo

    # Games
    mindustry-wayland

    # Windows
    wineWowPackages.waylandFull
  ];
}
