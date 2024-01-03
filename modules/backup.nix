{ config, lib, pkgs, ... }:

let
  cfg = config.services.backup;
in
{
  options.services.backup = {
    enable = lib.mkEnableOption "backup";

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
  };

  config = {
    assertions = [{
      assertion = cfg.paths != [ ] -> cfg.enable;
      message = "Configuring backup services.backup.paths without enabling services.backup.enable is useless!";
    }];

    services = {
      postgresqlBackup = {
        inherit (config.services.postgresql) enable;
        backupAll = true;
        startAt = "*-*-* 04:00:00";
      };

      restic.backups =
        let
          commonOpts = {
            extraBackupArgs = [
              "--exclude-file=${pkgs.writeText "restic-exclude-file" (lib.concatMapStrings (x: x + "\n") cfg.exclude)}"
            ];
            initialize = true;
            passwordFile = config.sops.secrets."restic/password".path;
            paths = [
              "/etc/group"
              "/etc/machine-id"
              "/etc/passwd"
              "/etc/shadow"
              "/etc/ssh/ssh_host_ed25519_key"
              "/etc/ssh/ssh_host_ed25519_key.pub"
              "/etc/ssh/ssh_host_rsa_key"
              "/etc/ssh/ssh_host_rsa_key.pub"
              "/etc/subgid"
              "/etc/subuid"
              "/var/lib/nixos/"
            ] ++ cfg.paths
            ++ lib.optional config.services.postgresql.enable "/var/backup/postgresql/"
            ++ lib.optional (config.security.acme.certs != { }) "/var/lib/acme/"
            ++ lib.optional config.security.dhparams.enable "/var/lib/dhparams/";
            pruneOpts = [
              "--group-by host"
              "--keep-daily 7"
              "--keep-weekly 4"
              "--keep-monthly 12"
            ];
            timerConfig = {
              OnCalendar = "*-*-* 04:30:00";
              RandomizedDelaySec = "5m";
            };
          };
        in
        lib.mkIf cfg.enable {
          server9 = commonOpts // {
            repositoryFile = config.sops.secrets."restic/repositories/server9".path;
          };
          offsite = commonOpts // {
            repository = "sftp://offsite/${config.networking.hostName}";
          };
        };
    };

    sops.secrets = lib.mkIf cfg.enable {
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

      # relies on defaultSopsFile
      "restic/password".owner = "root";
      "restic/repositories/server9".owner = "root";
    };

    system.activationScripts.linkResticSSHConfigIntoVirtioFS = lib.mkIf cfg.enable ''
      echo "Linking restic ssh config..."
      mkdir -m700 -p /home/root/.ssh/
      ln -fs {,/home}/root/.ssh/id_offsite-backup
      ln -fs {,/home}/root/.ssh/id_offsite-backup.pub
      ln -fs {,/home}/root/.ssh/config
    '';

    systemd = lib.mkIf cfg.enable {
      services = {
        restic-backups-server9.serviceConfig.Environment = "RESTIC_PROGRESS_FPS=0.016666";
        restic-backups-offsite.serviceConfig.Environment = "RESTIC_PROGRESS_FPS=0.016666";
      };
      timers = lib.mkIf config.services.postgresqlBackup.enable {
        postgresqlBackup.timerConfig.RandomizedDelaySec = "5m";
      };
    };
  };
}
