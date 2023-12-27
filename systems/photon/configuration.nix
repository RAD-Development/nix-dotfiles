{ config, pkgs, lib, ... }:
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

  security.acme = {
    acceptTerms = true;
    defaults = {
      dnsPropagationCheck = true;
      email = "info@wavelens.io";
    };
  };

  security.ldap.domainComponent = [ "wavelens" "io" ];

  services = {
    postgresql = {
      enable = true;
      recommendedDefaults = true;
      upgrade = {
        enable = true;
        stopServices = [
          "gitea"
          "nextcloud"
          "vaultwarden"
        ];
      };
    };

    portunus = {
      enable = true;
      addToHosts = true;
      # TODO
      # configureOAuth2Proxy = true;
      ldapPreset = true;
      removeAddGroup = true;
      domain = "auth.wavelens.io";
      seedGroups = true;
      seedSettings = {
        groups = [
          {
            long_name = "Portunus Administrators";
            name = "admins";
            members = [ "admin" ];
            permissions.portunus.is_admin = true;
          }
          {
            long_name = "Search";
            name = "search";
            members = [ "search" ];
            permissions.ldap.can_read = true;
          }
        ];

        users = [
          {
            family_name = "Administrator";
            given_name = "Initial";
            login_name = "admin";
            password.from_command = [ "/usr/bin/env" "cat" "/run/secrets/portunus/users/admin-password" ];
          }
          {
            email = "search@wavelens.io";
            family_name = "-";
            given_name = "Search";
            login_name = "search";
            password.from_command = [ "/usr/bin/env" "cat" "/run/secrets/portunus/users/search-password" ];
          }
        ];
      };

      ldap = {
        searchUserName = "search";
        suffix = "dc=wavelens,dc=io";
        tls = true;
      };
    };

    vaultwarden = {
      enable = true;
      configureNginx = true;
      domain = "bitwarden.wavelens.io";
      recommendedDefaults = true;
      config = {
        PUSH_ENABLED = true;
        PUSH_IDENTITY_URI = "https://identity.bitwarden.eu";
        PUSH_RELAY_URI = "https://push.bitwarden.eu";
        SENDMAIL_COMMAND = "/run/wrappers/bin/sendmail";
        SMTP_DEBUG = false;
        SMTP_FROM = "noreply@wavelens.io";
        SMTP_FROM_NAME = "Wavelens Vault";
        SHOW_PASSWORD_HINT = false;
        SIGNUPS_ALLOWED = false;
        USE_SENDMAIL = true;
      };
      dbBackend = "postgresql";
    };

    gitea = {
      enable = true;
      recommendedDefaults = true;
      lfs.enable = true;
      repositoryRoot = "/var/lib/gitea/repositories";
      database = {
        type = "postgres";
        createDatabase = true;
        passwordFile = config.sops.secrets."gitea/postgres-password".path;
      };

      ldap = {
        enable = true;
        adminGroup = "gitea-admins";
        userGroup = "user";
        bindPasswordFile = config.sops.secrets."gitea/ldap-password".path;
      };

      settings = {
        actions.ENABLED = true;
        "cron.delete_generated_repository_avatars".ENABLED = true;
        "cron.repo_health_check".TIMEOUT = "300s";
        database.LOG_SQL = false;
        # enable if it is actually useful
        # federation.ENABLED = true;
        indexer.REPO_INDEXER_ENABLED = true;
        log = {
          LEVEL = "Info";
          "logger.router.MODE" = "Warn";
          "logger.xorm.MODE" = "Warn";
        };
        mailer = {
          ENABLED = true;
          FROM = "gitea@wavelens.io";
          PROTOCOL = "sendmail";
          SENDMAIL_PATH = "/run/wrappers/bin/sendmail";
          SENDMAIL_ARGS = "--";
        };
        other.SHOW_FOOTER_VERSION = false;
        # disabled to prevent us becoming critical infrastructure, might revisit later
        packages.ENABLED = false;
        picture = {
          # this also disables libravatar
          DISABLE_GRAVATAR = false;
          ENABLE_FEDERATED_AVATAR = true;
          GRAVATAR_SOURCE = "libravatar";
          REPOSITORY_AVATAR_FALLBACK = "random";
        };
        repository.DEFAULT_REPO_UNITS = "repo.code,repo.releases,repo.issues,repo.pulls";
        server = rec {
          DOMAIN = "git.wavelens.io";
          ENABLE_GZIP = true;
          SSH_AUTHORIZED_KEYS_BACKUP = false;
          SSH_DOMAIN = DOMAIN;
        };
        service = {
          DISABLE_REGISTRATION = true;
          ENABLE_NOTIFY_MAIL = true;
          NO_REPLY_ADDRESS = "no_reply@wavelens.io";
          REGISTER_EMAIL_CONFIRM = true;
          USER_LOCATION_MAP_URL = "https://www.openstreetmap.org/search?query=";
        };
        session = {
          COOKIE_SECURE = lib.mkForce true;
          PROVIDER = "db";
          SAME_SITE = "strict";
        };
        "ssh.minimum_key_sizes" = {
          ECDSA = -1;
          RSA = 4095;
        };
        time.DEFAULT_UI_LOCATION = config.time.timeZone;
        ui = {
          DEFAULT_THEME = "arc-green";
          EXPLORE_PAGING_NUM = 25;
          FEED_PAGING_NUM = 50;
          ISSUE_PAGING_NUM = 25;
        };
      };
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

    openssh = {
      extraConfig = ''
          Match User gitea
            AllowAgentForwarding no
            AllowTcpForwarding no
            PermitTTY no
            X11Forwarding no
        '';
    };
  };

  sops = {
    defaultSopsFile = ./secrets.yaml;
    secrets = {
      "gitea/postgres-password".owner = "gitea";
      "gitea/ldap-password".owner = "gitea";
      "nextcloud/postgres-password".owner = "nextcloud";
      "portunus/users/admin-password".owner = "portunus";
      "portunus/users/search-password".owner = "portunus";
    };
  };

  system.stateVersion = "23.11";
}
