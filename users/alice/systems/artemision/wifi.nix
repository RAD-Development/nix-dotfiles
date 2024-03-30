{ config, ... }:
{
  networking.wireless = {
    enable = true;
    environmentFile = config.sops.secrets."wifi-env".path;
    networks = {
      "taetaethegae-2.0".psk = "@PASS_taetaethegae_20@";
      "k".psk = "@PASS_k@";
      "Bloomfield".psk = "@PASS_bloomfield@";
    };
  };

  networking.nameservers = [
    "192.168.76.1"
    "9.9.9.9"
  ];

  #pinentryPackage = pkgs.pinentry-rofi;
  services.resolved = {
    enable = true;
    dnssec = "true";
    domains = [ "~." ];
    fallbackDns = [
      "1.1.1.1#one.one.one.one"
      "1.0.0.1#one.one.one.one"
    ];
    dnsovertls = "true";
  };

  sops = {
    defaultSopsFile = ./secrets.yaml;
    secrets = {
      "wifi-env" = {
        owner = "root";
        restartUnits = [ "wpa_supplicant.service" ];
      };
    };
  };
}
