{ config, pkgs, lib, ... }:
{
  imports = [
    ./banner.nix
    ./gitea.nix
    ./nginx.nix
    ./wordpress.nix
  ];

  time.timeZone = "Europe/Berlin";
  console.keyMap = "de";
  i18n.supportedLocales = [ "de_DE.UTF-8/UTF-8" ];

  networking = {
    hostId = "7d76fab7";
    firewall = {
      pingLimit = "--limit 1/minute --limit-burst 5";
      allowedTCPPorts = [
        80
        8080
        443
        8443
        3306
        993
        465
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
    useSystemdBoot = true;
  };

  security.acme = {
    acceptTerms = true;
    preliminarySelfsigned = true;
    staging = false;
    defaults = {
      email = "info@wavelens.io";
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

  systemd.services.vaultwarden = {
    after = [ "postgresql.service" ];
    requires = [ "postgresql.service" ];
    serviceConfig = {
      StateDirectory = lib.mkForce "vaultwarden";
      EnvironmentFile = [ config.sops.secrets."vaultwarden/smtp-password".path ];
    };
  };

  services = {
    openssh.ports = [ 12 ];

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

      ensureUsers = map
        (user: {
          name = user;
          ensureDBOwnership = true;
        }) [
        "vaultwarden"
        "gitea"
        "nextcloud"
      ];

      ensureDatabases = [
        "vaultwarden"
        "gitea"
        "nextcloud"
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
          {
            long_name = "Vaultwarden Users";
            name = "vaultwarden-users";
          }
        ];

        users = [
          {
            email = "info@wavelens.io";
            family_name = "Administrator";
            given_name = "Initial";
            login_name = "admin";
            password.from_command = [ "/usr/bin/env" "cat" "${config.sops.secrets."portunus/users/admin-password".path}" ];
          }
          {
            email = "noreply@wavelens.io";
            family_name = "Master";
            given_name = "Search";
            login_name = "search";
            password.from_command = [ "/usr/bin/env" "cat" "${config.sops.secrets."portunus/ldap-password".path}" ];
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
      dbBackend = "postgresql";
      config = {
        DATABASE_URL = lib.mkForce "postgresql:///vaultwarden?host=/run/postgresql";
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
    };

    bitwarden-directory-connector-cli = {
      enable = true;
      domain = config.services.vaultwarden.config.DOMAIN;
      ldap = {
        ad = false;
        hostname = config.services.portunus.domain;
        port = 636;
        rootPath = "dc=wavelens,dc=io";
        ssl = true;
        startTls = false;
        username = "uid=search,ou=users,dc=wavelens,dc=io";
      };

      secrets = {
        bitwarden = {
          client_path_id = config.sops.secrets."vaultwarden/client-id".path;
          client_path_secret = config.sops.secrets."vaultwarden/client-secret".path;
        };
        ldap = config.sops.secrets."portunus/ldap-password".path;
      };

      sync = {
        creationDateAttribute = "";
        groups = true;
        groupFilter = "(cn=vaultwarden-*)";
        groupNameAttribute = "cn";
        groupObjectClass = "groupOfNames";
        groupPath = "ou=groups";
        largeImport = false;
        memberAttribute = "member";
        overwriteExisting = true;
        removeDisabled = true;
        revisionDateAttribute = "";
        useEmailPrefixSuffix = false;
        userEmailAttribute = "mail";
        userFilter = "(isMemberOf=cn=vaultwarden-users,ou=groups,dc=wavelens,dc=io)";
        userObjectClass = "person";
        userPath = "ou=users";
        users = true;
      };
    };

    # TODO: TEMP -> moving to postgres
    mysql = {
      enable = true;
      package = pkgs.mariadb;

      ensureDatabases = [
        "web_wp_hostoguest"
        "bookstack"
      ];

      ensureUsers = [
        {
          name = "bookstack";
          ensurePermissions = {
            "bookstack.*" = "ALL PRIVILEGES";
          };
        }
      ];
    };

    nextcloud = {
      enable = true;
      package = pkgs.nextcloud28;
      recommendedDefaults = true;
      configureImaginary = true;
      configureRedis = true;
      configurePreviewSettings = true;
      https = true;
      hostName = "cloud.wavelens.io";
      database.createLocally = false;
      config = {
        dbtype = "pgsql";
        dbname = "nextcloud";
        dbuser = "nextcloud";
        dbpassFile = config.sops.secrets."nextcloud/postgres-password".path;
        adminpassFile = config.sops.secrets."nextcloud/admin-password".path;
      };
    };

    redis.servers = {
      "redis" = {
        enable = true;
        port = 6379;
      };

      "rspamd" = {
        enable = true;
        port = 6380;
      };

      "bookstack" = {
        enable = true;
        port = 6381;
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

    rspamd = {
      enable = true;

      locals = {
        "groups.conf".text = ''
          symbols {
            "FORGED_RECIPIENTS" { weight = 0; }
          }'';
      };

      extraConfig = ''
        actions {
          reject = null;
          add_header = 6;
          greylist = 4;
        }
      '';
    };

    # TODO
    # rspamd-trainer = {
    #   enable = true;
    # };

    bookstack = {
      enable = true;
      appKeyFile = config.sops.secrets."bookstack/app-key".path;
      appURL = "https://${config.services.bookstack.hostname}";
      hostname = "wiki.wavelens.io";

      database = {
        user = "bookstack";
        passwordFile = config.sops.secrets."bookstack/mysql-password".path;
      };

      config = {
        CHACHE_DRIVER = "redis";
        SESSION_DRIVER = "redis";
        REDIS_SERVER = "127.0.0.1:${toString config.services.redis.servers."bookstack".port}:0";

        AUTH_METHOD = "ldap";
        LDAP_BASE_DN = "ou=users,dc=wavelens,dc=io";
        LDAP_DISPLAY_NAME_ATTRIBUTE = "cn";
        LDAP_DN = "uid=search,ou=users,dc=wavelens,dc=io";
        LDAP_ID_ATTRIBUT = "uid";
        LDAP_MAIL_ATTRIBUTE = "mail";
        LDAP_PASS = "${if (lib.pathExists config.sops.secrets."bookstack/ldap-password".path) then (builtins.readFile config.sops.secrets."bookstack/ldap-password".path) else ""}";
        LDAP_SERVER = "${config.services.portunus.domain}:636";
        LDAP_USER_FILTER = "(isMemberOf=cn=vaultwarden-users,ou=groups,dc=wavelens,dc=io)";
        LDAP_VERSION = 3;
      };
    };
  };

  mailserver = {
    enable = true;
    fqdn = "mail.wavelens.io";
    domains = [ "wavelens.io" ];
    certificateScheme = "acme-nginx";
    indexDir = "/var/lib/dovecot/indices";
    openFirewall = false;

    fullTextSearch = {
      enable = true;
      autoIndex = true;
      indexAttachments = true;
      enforced = "body";
    };

    loginAccounts = {
      "info@wavelens.io" = {
        hashedPasswordFile = config.sops.secrets."mailserver/mail-passwords/wavelens-info".path;
        aliases = [ "hey@wavelens.io" ];
      };

      "catch@wavelens.io" = {
        hashedPasswordFile = config.sops.secrets."mailserver/mail-passwords/wavelens-catch".path;
        catchAll = [ "wavelens.io" ];
      };

      "noreply@wavelens.io" = {
        hashedPasswordFile = config.sops.secrets."mailserver/mail-passwords/wavelens-noreply".path;
        sendOnly = true;
      };

      "dennis.wuitz@wavelens.io" = {
        hashedPasswordFile = config.sops.secrets."mailserver/mail-passwords/wavelens-dennis".path;
      };
    };

    # ldap = {
    #   enable = true;
    #   uris = [ "ldaps://${config.services.portunus.domain}" ];
    #   searchBase = "ou=users,dc=wavelens,dc=io";
    #   searchScope = "sub";
    #   # userAttrs = ''

    #   # '';

    #   bind = {
    #     dn = "uid=${config.services.portunus.ldap.searchUserName},ou=users,dc=wavelens,dc=io";
    #     passwordFile = config.sops.secrets."mailserver/ldap-password".path;
    #   };
    # };
  };

  sops = {
    defaultSopsFile = ./secrets.yaml;
    secrets = {
      "bookstack/app-key".owner = "bookstack";
      "bookstack/mysql-password".owner = "bookstack";
      "bookstack/ldap-password".owner = "bookstack";
      "gitea/postgres-password".owner = "gitea";
      "gitea/ldap-password".owner = "gitea";
      "nextcloud/postgres-password".owner = "nextcloud";
      "nextcloud/admin-password".owner = "nextcloud";
      "nextcloud/ldap-password".owner = "nextcloud";
      "mailserver/ldap-password".owner = "dovecot2";
      "mailserver/mail-passwords/wavelens-info".owner = "dovecot2";
      "mailserver/mail-passwords/wavelens-catch".owner = "dovecot2";
      "mailserver/mail-passwords/wavelens-noreply".owner = "dovecot2";
      "mailserver/mail-passwords/wavelens-dennis".owner = "dovecot2";
      "portunus/users/admin-password".owner = "portunus";
      "portunus/ldap-password".owner = "portunus";
      "wordpress/hostoguest-password".owner = "wordpress";
      "vaultwarden/smtp-password".owner = "vaultwarden";
      "vaultwarden/client-id".owner = "vaultwarden";
      "vaultwarden/client-secret".owner = "vaultwarden";
      "vaultwarden/ldap-password".owner = "vaultwarden";
    };
  };

  system.stateVersion = "23.11";
}
