{ config, pkgs, lib, ... }: {
  imports = [
    ./banner.nix
    ./gitea.nix
    ./nginx.nix
    ./mailserver.nix
    ./vaultwarden.nix
  ];

  time.timeZone = "Europe/Berlin";
  console.keyMap = "de";
  i18n.supportedLocales = [ "de_DE.UTF-8/UTF-8" ];
  boot.useSystemdBoot = true;
  security.ldap.domainComponent = [ "wavelens" "io" ];
  home-manager.users.itmg = (import ./../../users/dennis/home.nix);
  users.users = {
    nginx.extraGroups = [ "acme" ];
    itmg = {
      name = "itmg";
      isNormalUser = true;
      extraGroups = [ "minecraft" ];
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJutsFUQW7YDSU7dlb9rxYGI+FFqVKrIXpR5skP0u6+N arobrame@gmail.com" ]
        ++ config.users.users.dennis.openssh.authorizedKeys.keys;
    };
  };

  networking = {
    hostId = "7d76fab7";
    domain = "wavelens.io";
    nftables.enable = true;
    firewall = {
      filterForward = true;
      allowedTCPPorts = [
        25
        80
        143
        443
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

  security.acme = {
    acceptTerms = true;
    preliminarySelfsigned = true;
    staging = false;
    defaults = {
      email = "security@wavelens.io";
      dnsProvider = "rfc2136";
      group = "nginx";
    };
  };

  systemd = {
    tmpfiles.rules = [ "Z /var/lib/minecraft 0770 - minecraft - -" ];
    services.vaultwarden = {
      after = [ "postgresql.service" ];
      requires = [ "postgresql.service" ];
      serviceConfig = {
        StateDirectory = lib.mkForce "vaultwarden";
        EnvironmentFile = [ config.sops.secrets."vaultwarden/smtp-password".path ];
      };
    };
  };

  services = {
    openssh.ports = [ 12 ];
    backup = {
      enable = true;
      paths = [
        "/var/lib/dovecot/"
        "/var/lib/minecraft/"
        "/var/lib/nextcloud/"
        "/var/lib/outline/"
        "/var/lib/paperless/"
        "/var/lib/portunus/"
        "/var/lib/postfix/"
        "/var/lib/private/"
        "/var/lib/rspamd/"
        "/var/lib/vaultwarden/"
        "/var/lib/www/"
      ];
    };

    postgresql = {
      enable = true;
      enableJIT = true;
      ensureDatabases = [ "gitea" "nextcloud" "vaultwarden" "outline" "paperless" ];
      ensureUsers = map (user: {
        name = user;
        ensureDBOwnership = true;
      }) [ "gitea" "nextcloud" "vaultwarden" "outline" "paperless" ];

      upgrade = {
        enable = true;
        stopServices = [ "gitea" "nextcloud" "vaultwarden" "outline" "paperless" ];
      };
    };

    portunus = {
      enable = true;
      addToHosts = true;
      ldapPreset = true;
      removeAddGroup = true;
      domain = "auth.wavelens.io";
      port = 3890;
      seedGroups = true;
      seedSettings = {
        groups = [
          {
            long_name = "LDAP Administrators";
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
          {
            long_name = "Nextcloud Users";
            name = "nextcloud-users";
          }
          {
            long_name = "Mail Account";
            name = "mail-account";
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

    mysql = {
      enable = true;
      package = pkgs.mariadb;
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

    paperless = {
      enable = true;
      passwordFile = config.sops.secrets."paperless/admin-password".path; # TODO: Add password
      settings = {
        PAPERLESS_ADMIN_MAIL = "info@wavelens.io";
        PAPERLESS_ADMIN_USER = "wavelens";
        PAPERLESS_CONSUMER_IGNORE_PATTERN = [ ".DS_STORE/*" "desktop.ini" ];
        PAPERLESS_CONSUMER_RECURSIVE = true;
        PAPERLESS_CONSUMER_SUBDIRS_AS_TAGS = true;
        PAPERLESS_DBHOST = "/run/postgresql";
        PAPERLESS_EMAIL_TASK_CRON = "*/20 * * * *";
        PAPERLESS_ENABLE_COMPRESSION = false;
        PAPERLESS_IGNORE_DATES = "24.08.2000";
        PAPERLESS_INDEX_TASK_CRON = "8 0 * * *";
        PAPERLESS_OCR_SKIP_ARCHIVE_FILE = "with_text";
        PAPERLESS_OCR_LANGUAGE = "deu+eng";
        PAPERLESS_TIME_ZONE = "Europe/Berlin";
        PAPERLESS_TRUSTED_PROXIES = "127.0.0.1";
        PAPERLESS_URL = "https://paper.wavelens.io";
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

        "api-wiki" = {
          root = "apidocs.wavelens.io";
          subdomain = "api-wiki";
          domain = "wavelens.io";
        };
      };
    };

    rspamd = {
      enable = true;
      postfix.enable = true;
      overrides."password" = {
        enable = true;
        source = pkgs.outline + /etc/rspamd/local.d/worker-controller.inc;
        text = ''password = "$2$kxdcg8hm9kibsh11ach6414mpc13xj8x$6uowb81a7szosq81ay61owwo4jy1magr53rg59qkj34nzxx39kab"'';
      };

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

    minecraft-server = {
      enable = true;
      eula = true;
      openFirewall = true;
      package = pkgs.papermc;
    };

    factorio = {
      enable = true;
      openFirewall = true;
      package = pkgs.factorio-headless;
      extraSettingsFile = lib.mkIf (builtins.pathExists /var/lib/${config.services.factorio.stateDirName}) /var/lib/${config.services.factorio.stateDirName}/server-settings.json;
    };

    outline = {
      # LDAP: https://github.com/outline/outline/issues/1881
      enable = true;
      port = 3120;
      storage.storageType = "local";
      logo = "https://static.wavelens.io/logo/logo.svg";
      publicUrl = "https://wiki.wavelens.io";
      smtp = {
        fromEmail = "wiki@wavelens.io";
        host = "mail.wavelens.io";
        secure = true;
        tlsCiphers = "SSLv3";
        passwordFile = config.sops.secrets."outline/smtp-password".path;
        port = 465;
        replyEmail = "info@wavelens.io";
        username = "wiki@wavelens.io";
      };
    };
  };

  sops = {
    defaultSopsFile = ./secrets.yaml;
    secrets = {
      "gitea/ldap-password".owner = "gitea";
      "gitea/postgres-password".owner = "gitea";
      "mailserver/ldap-password".owner = "dovecot2";
      "mailserver/mail-passwords/wavelens-catch".owner = "dovecot2";
      "mailserver/mail-passwords/wavelens-cloud".owner = "dovecot2";
      "mailserver/mail-passwords/wavelens-dennis".owner = "dovecot2";
      "mailserver/mail-passwords/wavelens-git".owner = "dovecot2";
      "mailserver/mail-passwords/wavelens-info".owner = "dovecot2";
      "mailserver/mail-passwords/wavelens-noreply".owner = "dovecot2";
      "mailserver/mail-passwords/wavelens-vault".owner = "dovecot2";
      "mailserver/mail-passwords/wavelens-wiki".owner = "dovecot2";
      "nextcloud/admin-password".owner = "nextcloud";
      "nextcloud/ldap-password".owner = "nextcloud";
      "nextcloud/postgres-password".owner = "nextcloud";
      "outline/smtp-password".owner = "outline";
      "paperless/admin-password".owner = "paperless";
      "portunus/ldap-password".owner = "portunus";
      "portunus/users/admin-password".owner = "portunus";
      "vaultwarden-connector/client-id".owner = "bwdc";
      "vaultwarden-connector/client-secret".owner = "bwdc";
      "vaultwarden-connector/ldap-password".owner = "bwdc";
      "vaultwarden/smtp-password".owner = "vaultwarden";
    };
  };

  system.stateVersion = "23.11";
}
