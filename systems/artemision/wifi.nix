{ config, ... }:
let
  always = 100;
  home = 99;
in
{
  networking.wireless = {
    enable = true;
    environmentFile = config.sops.secrets."wifi-env".path;
    userControlled.enable = true;
    networks = {
      "taetaethegae-2.0" = {
        psk = "@PASS_taetaethegae_20@";
        priority = home;
      };
      "k" = {
        psk = "@PASS_k@";
        priority = always;
      };
      "Bloomfield".psk = "@PASS_bloomfield@";
      "9872441500".psk = "@PASS_longboat_home@";
      "9872441561".psk = "@PASS_longboat_home@";
      "5HuFios".psk = "@PASS_longboat_home@";
      "24HuFios".psk = "@PASS_longboat_home@";
      "optimumwifi" = { };
      "CableWiFi" = { };
    };
  };

  networking.nameservers = [
    "9.9.9.9"
    "1.1.1.1"
    "192.168.76.1"
  ];

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
