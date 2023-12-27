{ config, pkgs, lib, ... }:
{
  imports = [
    ./banner.nix
    ./nginx.nix
  ];

  time.timeZone = "Europe/Berlin";
  console.keyMap = "de";
  i18n.supportedLocales = [ "de_DE.UTF-8/UTF-8" ];

  networking = {
    hostId = "7d76fab7";
    firewall = {
      allowedTCPPorts = [
        80
        443
        3306
      ];
    };
    interfaces = {
      ens3.ipv6.addresses = [{
        address = "2a03:4000:57:b96::1";
        prefixLength = 64;
      }];
    };
    defaultGateway6 = {
      address = "fe80::1";
      interface = "ens3";
    };
  };

  boot = {
    filesystem = "ext4";
    useSystemdBoot = true;
  };

  security.acme = {
    acceptTerms = true;
    preliminarySelfsigned = true;
    staging = false;
    defaults = {
      email = "info@wavelens.io";
      postRun = "systemctl restart nginx.service";
      dnsProvider = "rfc2136";
      group = "nginx";
    };

    certs = {
      "hostoguest.ai" = {
        email = "office@hostoguest.ai";
      };
      "app.hostoguest.ai" = {
        email = "office@hostoguest.ai";
      };
    };
  };
  users.users.nginx.extraGroups = [ "acme" ];

  security.ldap.domainComponent = [ "wavelens" "io" ];

  services = {
    postgresql = {
      enable = true;
      enableJIT = true;
      upgrade = {
        enable = true;
        stopServices = [
          "gitea"
          "nextcloud"
          "vaultwarden"
        ];
      };

      ensureUsers = map(user: { 
        name = user;
        ensureDBOwnership = true;
      }) [
        "web_vaultwarden"
        "web_gitea"
        "web_nextcloud"
        "web_wp_hostoguest"
      ];

      ensureDatabases = [
        "web_vaultwarden"
        "web_gitea"
        "web_nextcloud"
        "web_wp_hostoguest"
      ];
    };

    portunus = {
      enable = true;
      addToHosts = true;
      # TODO
      # configureOAuth2Proxy = true;
      ldapPreset = true;
      removeAddGroup = true;
      domain = "auth.wavelens.io";
      port = 3890;
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
            family_name = "Master";
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
      config = {
        DATABASE_URL = lib.mkForce "postgresql:///web_vaultwarden?host=/run/postgresql";
        DOMAIN = "https://bitwarden.wavelens.io";
        DATA_FOLDER = "/var/lib/vaultwarden";
        PUSH_ENABLED = false;
        PUSH_IDENTITY_URI = "https://identity.bitwarden.eu";
        PUSH_RELAY_URI = "https://push.bitwarden.eu";
        # SMTP_DEBUG = false;
        # SMTP_HOST = "crux.uberspace.de";
        # SMTP_PORT = 587;
        # SMTP_FROM = "vault@wavelens.io";
        # SMTP_SECURITY = "starttls";
        # SMTP_USERNAME = "vault@wavelens.io";
        # SMTP_PASSWORD = lib.mkIf (lib.pathIsRegularFile config.sops.secrets."vaultwarden/smtp-password".path) (lib.readFile config.sops.secrets."vaultwarden/smtp-password".path);
        # SMTP_FROM_NAME = "Wavelens Vault";
        SHOW_PASSWORD_HINT = false;
        SIGNUPS_ALLOWED = false;
        LOG_LEVEL = "warn";
        PASSWORD_ITERATIONS = 600000;
        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = 8222;
        SIGNUPS_VERIFY = false;
        TRASH_AUTO_DELETE_DAYS = 30;
        WEBSOCKET_ADDRESS = "127.0.0.1";
        WEBSOCKET_ENABLED = true;
        WEBSOCKET_PORT = 8223;
      };
      dbBackend = "postgresql";
    };

    # TODO: TEMPORAY
    mysql = {
      enable = true;
      package = pkgs.mariadb;
      ensureUsers = [
        # {
        #   name = "nextcloud";
        #   ensurePermissions = {
        #     "web_nextcloud.*" = "ALL PRIVILEGES";
        #   };

        # }
        # {
        #   name = "gitea";
        #   ensurePermissions = {
        #     "web_gitea.*" = "ALL PRIVILEGES";
        #   };
        # }
        # {
        #   name = "web_wp_hostoguest";
        #   ensurePermissions = {
        #     "web_wp_hostoguest.*" = "ALL PRIVILEGES";
        #   };
        # }
      ];
      ensureDatabases = [
        # "web_nextcloud"
        # "web_gitea"
        # "web_wp_hostoguest"
      ];
    };

    gitea = {
      enable = true;
      recommendedDefaults = true;
      lfs.enable = false;
      repositoryRoot = "/var/lib/gitea/repositories";
      database = {
        createDatabase = false;
        type = "mysql";
        name = "web_gitea";
        user = "web_gitea";
        passwordFile = config.sops.secrets."gitea/postgres-password".path;
      };

      ldap = {
        enable = true;
        adminGroup = "gitea-admins";
        userGroup = "gitea-users";
        searchUserPasswordFile = config.sops.secrets."gitea/ldap-password".path;
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
          ENABLED = false;
          FROM = "git@wavelens.io";
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
          ENABLE_NOTIFY_MAIL = false;
          NO_REPLY_ADDRESS = "noreply@wavelens.io";
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
      database.createLocally = false;
      config = {
        dbtype = "mysql";
        dbname = "web_nextcloud";
        dbuser = "web_nextcloud";
        dbpassFile = config.sops.secrets."nextcloud/postgres-password".path;
        adminpassFile = config.sops.secrets."nextcloud/admin-password".path;
      };
    };

    redis.servers."redis" = {
      enable = true;
      port = 6379;
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

    wordpress = {
      webserver = "nginx";
      sites = {
        "hostoguest.ai".database = {
          createLocally = false;
          name = "web_wp_hostoguest";
          user = "web_wp_hostoguest";
          passwordFile = config.sops.secrets."wordpress/hostoguest-password".path;
        };
      };
    };

    staticpage = {
      enable = true;
      sites = {
        "homepage" = {
          root = "wavelens.io";
          domain = "wavelens.io";
        };
        "static" = {
          root = "static.wavelens.io";
          subdomain = "static";
          domain = "wavelens.io";
        };
      };
    };
  };

  sops = {
    defaultSopsFile = ./secrets.yaml;
    secrets = {
      "gitea/postgres-password".owner = "gitea";
      "gitea/ldap-password".owner = "gitea";
      "nextcloud/postgres-password".owner = "nextcloud";
      "nextcloud/admin-password".owner = "nextcloud";
      "portunus/users/admin-password".owner = "portunus";
      "portunus/users/search-password".owner = "portunus";
      "wordpress/hostoguest-password".owner = "wordpress";
      "vaultwarden/smtp-password".owner = "vaultwarden";
    };
  };

  system.stateVersion = "23.11";
}
