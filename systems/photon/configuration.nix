{ config, pkgs, ... }:
{
  imports = [
    ./banner.nix
    ./nginx.nix
  ];

  time.timeZone = "Europe/Berlin";
  console.keyMap = "de";
  i18n.supportedLocales = [ "de_DE.UTF-8/UTF-8" ];

  networking.hostId = "7d76fab7";

  boot = {
    filesystem = "ext4";
    useSystemdBoot = true;
  };

  security = {
    acme = {
      acceptTerms = true;
    };
    ldap = {
      domainComponent = [ "wavelens" "io" ];
    };
  };

  services = {
    # acme-dns = {
    #   enable = true;
    #   settings = {
    #     general.domain = "wavelens.io";
    #   };
    # };

    postgresql = {
      enable = true;
      recommendedDefaults = true;
      upgrade = {
        enable = true;
      };
    };

    portunus = {
      enable = true;
      addToHosts = true;
      # TODO
      # configureOAuth2Proxy = true;
      ldapPreset = true;
      seedGroups = true;
      # seedSettings = true;
      domain = "ldap.wavelens.io";
      ldap = {
        suffix = "dc=example,dc=com";
      };
    };

    vaultwarden = {
      enable = true;
      configureNginx = true;
      domain = "bitwarden.wavelens.io";
      recommendedDefaults = true;
    };

    gitea = {
      enable = true;
      recommendedDefaults = true;
      lfs.enable = true;
      database = {
        type = "postgres";
        createDatabase = true;
        passwordFile = config.sops.secrets."gitea/postgres-password".path;
      };

      # ldap = {
      #   enable = true;
      #   adminGroup = "gitea-admins";
      #   userGroup = "user";
      #   ldapSearchUserPasswordFile = config.sops.secrets."gitea/ldap-password".path;
      # };
    };

    nextcloud = {
      enable = true;
      package = pkgs.nextcloud27;
      recommendedDefaults = true;
      configureImaginary = true;
      configureRedis = true;
      configurePreviewSettings = true;
      https = true;
      hostName = "cloud.wavelens.io";
      database.createLocally = true;
      config = {
        dbtype = "pgsql";
        adminpassFile = config.sops.secrets."nextcloud/postgres-password".path;
      };
    };

    redis.servers."redis" = {
      port = 6379;
      openFirewall = true;
    };
  };

  sops = {
    defaultSopsFile = ./secrets.yaml;
    secrets = {
      "gitea/postgres-password".owner = "gitea";
      "gitea/ldap-password".owner = "gitea";
      "nextcloud/postgres-password".owner = "nextcloud";
    };
  };

  system.stateVersion = "23.11";
}
