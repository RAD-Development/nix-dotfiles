{ pkgs, ... }:
{
  systemd = {
    services."plex_permission" = {
      description = "maintains /zfs/storage/plex permissions";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.bash}/bin/bash ${./scripts/plex_permission.sh}";
      };
    };
    timers."plex_permission" = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "1h";
        OnCalendar = "daily 03:00";
        Unit = "plex_permission.service";
      };
    };
  };
}
