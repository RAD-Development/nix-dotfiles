{ config, ... }:

{
  services.syncthing = {
    enable = true;
    user = "richie";
    overrideDevices = true;
    overrideFolders = true;
    dataDir = "/home/richie/Syncthing";
    configDir = "/home/richie/.config/syncthing";
    settings = {
      gui = {
        user = "richie";
        password.from_command = [
          "/usr/bin/env"
          "cat"
          "${config.sops.secrets."syncthing/password".path}"
        ];
      };
      devices = {
        phone.id = "LTGPLAE-M4ZDJTM-TZ3DJGY-SLLAVWF-CQDVEVS-RGCS75T-GAPZYK3-KUM6LA5";
        jeeves.id = "7YQ4UEW-OPQEBH4-6YKJH4B-ZCE3SAX-5EIK5JL-WJDIWUA-WA2N3D5-MNK6GAV";
        rhapsody-in-green.id = "INKUNKN-KILXGL5-2TQ5JTH-ORJOLOM-WYD2PYO-YRDLQIX-3AKZFWT-ZN7OJAE";
      };
    };
  };
  sops = {
    defaultSopsFile = ./secrets.yaml;
    secrets = {
      "syncthing/password".owner = "richie";
    };
  };
}
