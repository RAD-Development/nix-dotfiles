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
  users.users.nginx.extraGroups = [ "acme" ];
  security.ldap.domainComponent = [ "wavelens" "io" ];
  networking = {
    hostId = "7d76fab7";
    domain = "wavelens.io";
    nftables.enable = true;
    firewall = {
      filterForward = true;
      allowedTCPPorts = [ 25 80 143 443 3306 993 465 ];
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
    timers.bitwarden-directory-connector-cli.wants = [ "network-online.target" ]; # TODO: TEMPORARY
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
        "/var/lib/nextcloud/"
        "/var/lib/outline/"
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
      ensureDatabases = [ "gitea" "nextcloud" "vaultwarden" "outline" ];
      ensureUsers = map
        (user: {
          name = user;
          ensureDBOwnership = true;
        }) [ "gitea" "nextcloud" "vaultwarden" "outline" ];

      upgrade = {
        enable = true;
        stopServices = [ "gitea" "nextcloud" "vaultwarden" "outline" ];
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

    # TODO
    # rspamd-trainer = {
    #   enable = true;
    # };

    outline = {
      # LDAP: https://github.com/outline/outline/issues/1881
      enable = true;
      port = 3120;
      storage.storageType = "local";
      logo = "https://static.wavelens.io/logo/logo.svg";
      smtp = {
        fromEmail = "wiki@wavelens.io";
        host = "localhost";
        passwordFile = config.sops.secrets."outline/smtp-password".path;
        port = 25;
        replyEmail = "wiki@wavelens.io";
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
