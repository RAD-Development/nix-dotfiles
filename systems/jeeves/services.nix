{
  config,
  inputs,
  pkgs,
  ...
}:
{
  systemd = {
    services = {
      plex_permission = {
        description = "maintains /zfs/storage/plex permissions";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.bash}/bin/bash ${./scripts/plex_permission.sh}";
        };
      };
      startup_validation = {
        wantedBy = [ "multi-user.target" ];
        description = "validates startup";
        path = [ pkgs.zfs ];
        serviceConfig = {
          Environment = config.sops.secrets."server-validation/webhook".path;
          Type = "oneshot";
          ExecStart = "${inputs.server_tools.packages.x86_64-linux.default}/bin/validate_jeeves";
        };
      };
    };
    timers = {
      plex_permission = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "1h";
          OnCalendar = "daily 03:00";
          Unit = "plex_permission.service";
        };
      };
      startup_validation = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "10min";
          Unit = "startup_validation.service";
        };
      };
    };
  };
  sops = {
    defaultSopsFile = ./secrets.yaml;
    secrets."server-validation/webhook".owner = "root";
  };
}
