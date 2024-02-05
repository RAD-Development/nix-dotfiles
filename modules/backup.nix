{ config, lib, pkgs, ... }:

let cfg = config.services.backup;
in {
  options.services.backup = {
    enable = lib.mkEnableOption "backup";

    offsite = lib.mkOption {
      type = with lib.types; listOf str;
      default = [ ];
      description = "Offsite backup hostnames.";
    };

    paths = lib.mkOption {
      type = with lib.types; listOf str;
      default = [ ];
      description = "Extra paths to include in backup.";
    };

    exclude = lib.mkOption {
      type = with lib.types; listOf str;
      default = [ ];
      description = "Extra paths to exclude in backup.";
    };

    backup_at = lib.mkOption {
      type = lib.types.int;
      default = 2;
      description = "Time to run backup.";
    };
  };

  config = {
    assertions = [
      {
        assertion = cfg.paths != [ ] -> cfg.enable;
        message = "Configuring backup services.backup.paths without enabling services.backup.enable is useless!";
      }
      {
        assertion = cfg.backup_at < 24;
        message = "Backup time must be less than 24 hours!";
      }
    ];

    services = {
      postgresqlBackup = {
        inherit (config.services.postgresql) enable;
        backupAll = true;
        startAt = "*-*-* ${lib.fixedWidthString 2 "0" (toString cfg.backup_at)}:00:00";
      };

      restic.backups =
        let
          commonOpts = {
            initialize = true;
            extraBackupArgs = [ "--exclude-file=${pkgs.writeText "restic-exclude-file" (lib.concatMapStrings (x: x + "\n") cfg.exclude)}" ];
            pruneOpts = [ "--group-by host" "--keep-daily 7" "--keep-weekly 4" "--keep-monthly 12" ];
            passwordFile = config.sops.secrets."restic/password".path;
            paths = [
              "/etc/group"
              "/etc/machine-id"
              "/etc/passwd"
              "/etc/shadow"
              "/etc/ssh/ssh_host_ecdsa_key"
              "/etc/ssh/ssh_host_ecdsa_key.pub"
              "/etc/ssh/ssh_host_ed25519_key"
              "/etc/ssh/ssh_host_ed25519_key.pub"
              "/etc/ssh/ssh_host_rsa_key"
              "/etc/ssh/ssh_host_rsa_key.pub"
              "/etc/subgid"
              "/etc/subuid"
              "/var/lib/nixos/"
            ] ++ cfg.paths
            ++ lib.optional config.services.postgresql.enable "/var/backup/postgresql/"
            ++ lib.optional config.services.mysql.enable "/var/lib/mysql/"
            ++ lib.optional config.services.gitea.enable "/var/lib/gitea/"
            ++ lib.optional (config.security.acme.certs != { }) "/var/lib/acme/"
            ++ lib.optional config.security.dhparams.enable "/var/lib/dhparams/"
            ++ lib.optional config.mailserver.enable config.mailserver.mailDirectory;

            exclude = lib.mkIf config.services.gitea.enable [
              "/var/lib/gitea/data/indexers/"
              "/var/lib/gitea/data/repo-archive"
              "/var/lib/gitea/data/queues"
              "/var/lib/gitea/data/tmp/"
            ];

            timerConfig = {
              OnCalendar = "*-*-* ${lib.fixedWidthString 2 "0" (toString cfg.backup_at)}:30:00";
              RandomizedDelaySec = "5m";
            };
          };
        in
        lib.mkIf cfg.enable {
          local = commonOpts // { repository = "/var/backup"; };
          offsite = lib.mkIf (cfg.offsite != [ ]) commonOpts // { repository = "sftp://offsite/${config.networking.hostName}"; };
        };
    };

    sops.secrets = lib.mkIf (cfg.enable && cfg.offsite != [ ]) {
      "restic/offsite/private" = {
        owner = "root";
        path = "/root/.ssh/id_offsite-backup";
        sopsFile = ./backup.yaml;
      };

      "restic/offsite/public" = {
        owner = "root";
        path = "/root/.ssh/id_offsite-backup.pub";
        sopsFile = ./backup.yaml;
      };

      "restic/offsite/ssh-config" = {
        owner = "root";
        path = "/root/.ssh/config";
        sopsFile = ./backup.yaml;
      };
    } // lib.mkIf cfg.enable { "restic/password".owner = "root"; };

    system.activationScripts.linkResticSSHConfigIntoVirtioFS = lib.mkIf (cfg.enable && cfg.offsite != [ ]) ''
      echo "Linking restic ssh config..."
      mkdir -m700 -p /home/root/.ssh/
      ln -fs {,/home}/root/.ssh/id_offsite-backup
      ln -fs {,/home}/root/.ssh/id_offsite-backup.pub
      ln -fs {,/home}/root/.ssh/config
    '';

    systemd = lib.mkIf cfg.enable {
      timers = lib.mkIf config.services.postgresqlBackup.enable { postgresqlBackup.timerConfig.RandomizedDelaySec = "5m"; };
      services = {
        restic-backups-local.serviceConfig.Environment = "RESTIC_PROGRESS_FPS=0.016666";
        restic-backups-offsite.serviceConfig.Environment = lib.mkIf (cfg.offsite != [ ]) "RESTIC_PROGRESS_FPS=0.016666";
      };
    };
  };
}
