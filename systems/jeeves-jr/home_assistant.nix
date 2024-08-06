{
  services.home-assistant = {
    enable = true;
    openFirewall = true;
    config = {
      server_port = 8123;
      homeassistant = {
        time_zone = "America/New_York";
        unit_system = "imperial";
        temperature_unit = "F";
        longitude = 40.74;
        latitude = 74.03;
      };
    };
  };
}
