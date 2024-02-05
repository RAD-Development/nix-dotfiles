{ lib, config, ... }:
{
  systemd.services.vaultwarden.serviceConfig.ReadWriteDir = [ "/var/lib/postfix/queue/maildrop/" ];
  services = {
    vaultwarden = {
      enable = true;
      dbBackend = "postgresql";
      config = {
        DATABASE_URL = lib.mkForce "postgresql:///vaultwarden?host=/run/postgresql";
        DATA_FOLDER = "/var/lib/vaultwarden";
        DOMAIN = "https://vault.wavelens.io";
        LOG_LEVEL = "warn";
        PASSWORD_ITERATIONS = 600000;
        PUSH_ENABLED = false;
        PUSH_IDENTITY_URI = "https://identity.bitwarden.eu";
        PUSH_RELAY_URI = "https://push.bitwarden.eu";
        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = 8222;
        SENDMAIL_COMMAND = "/run/wrappers/bin/sendmail";
        SHOW_PASSWORD_HINT = false;
        SIGNUPS_ALLOWED = false;
        SIGNUPS_VERIFY = false;
        SMTP_DEBUG = false;
        SMTP_FROM = "vault@wavelens.io";
        SMTP_FROM_NAME = "Vaultwarden";
        TRASH_AUTO_DELETE_DAYS = 30;
        USE_SENDMAIL = true;
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
        ldap = config.sops.secrets."vaultwarden/ldap-password".path;
        bitwarden = {
          client_path_id = config.sops.secrets."vaultwarden-connector/client-id".path;
          client_path_secret = config.sops.secrets."vaultwarden-connector/client-secret".path;
        };
      };

      sync = {
        creationDateAttribute = "";
        groupFilter = "(cn=vaultwarden-*)";
        groupNameAttribute = "cn";
        groupObjectClass = "groupOfNames";
        groupPath = "ou=groups";
        groups = true;
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
  };
}
