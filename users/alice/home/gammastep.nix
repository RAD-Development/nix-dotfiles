{ ... }:
{
  services.gammastep = {
    enable = true;
    provider = "manual";
    latitude = 40.73;
    longitude = -73.93;
    temperature.day = 5700;
    temperature.night = 3500;
    settings = {
      general = {
        fade = 1;
        elevation-high = 3;
        elevation-low = -6;
        brightness-day = 1.0;
        brightness-low = 0.8;
      };
    };
  };
}
