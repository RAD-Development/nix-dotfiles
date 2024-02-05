{ config, lib, ... }: {
  systemd.services.gitea.serviceConfig.ReadWriteDir = [ "/var/lib/postfix/queue/maildrop/" ];
  services.gitea = {
    enable = true;
    appName = "Wavelens Repository";
    recommendedDefaults = true;
    lfs.enable = true;
    repositoryRoot = "/var/lib/gitea/repositories";
    database.type = "postgres";

    ldap = {
      enable = true;
      adminGroup = "gitea-admins";
      userGroup = "gitea-users";
      searchUserPasswordFile = config.sops.secrets."gitea/ldap-password".path;
      options = {
        security-protocol = "LDAPS";
        host = config.services.portunus.domain;
        port = 636;
        user-search-base = "ou=users,dc=wavelens,dc=io";
        username-attribute = "uid";
        surname-attribute = "sn";
        email-attribute = "mail";
      };
    };

    settings = {
      actions.ENABLED = true;
      "cron.delete_generated_repository_avatars".ENABLED = true;
      "cron.repo_health_check".TIMEOUT = "300s";
      database.LOG_SQL = false;

      indexer.REPO_INDEXER_ENABLED = true;

      log = {
        LEVEL = "Info";
        "logger.router.MODE" = "Warn";
        "logger.xorm.MODE" = "Warn";
      };

      mailer = {
        ENABLED = true;
        FROM = "git@wavelens.io";
        PROTOCOL = "sendmail";
        SENDMAIL_PATH = "/run/wrappers/bin/sendmail";
        SENDMAIL_ARGS = "--";
      };

      other.SHOW_FOOTER_VERSION = false;
      packages.ENABLED = false;
      picture = {
        DISABLE_GRAVATAR = false;
        ENABLE_FEDERATED_AVATAR = true;
        GRAVATAR_SOURCE = "libravatar";
        REPOSITORY_AVATAR_FALLBACK = "random";
      };

      repository = {
        DISABLE_HTTP_GIT = true;
        DEFAULT_REPO_UNITS = "repo.code,repo.releases,repo.issues,repo.pulls";
      };

      server = rec {
        DOMAIN = "git.wavelens.io";
        ENABLE_GZIP = true;
        SSH_AUTHORIZED_KEYS_BACKUP = false;
        SSH_DOMAIN = DOMAIN;
        SSH_PORT = 12;
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

      time.DEFAULT_UI_LOCATION = config.time.timeZone;

      ui = {
        DEFAULT_THEME = "arc-green";
        EXPLORE_PAGING_NUM = 25;
        FEED_PAGING_NUM = 50;
        ISSUE_PAGING_NUM = 25;
      };
    };
  };
}
