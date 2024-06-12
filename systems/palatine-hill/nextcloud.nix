{
  config,
  lib,
  pkgs,
  ...
}:

{
  systemd.timers."nextcloud-pre-generate" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = 600;
      OnUnitActiveSec = 600;
      Unit = "nextcloud-pre-generate.service";
    };
  };

  systemd.services."nextcloud-pre-generate" = {
    requires = [
      "docker.service"
      "multi-user.target"
    ];
    after = [
      "docker.service"
      "multi-user.target"
    ];
    description = "incrementally pre-generates previews on nextcloud";
    serviceConfig = {
      Type = "oneshot";
      DynamicUser = "yes";
      Group = "docker";
      ExecStart = ''
        docker ps --format "{{.Names}}" | grep -q "^nextcloud-nextcloud-1$" && docker exec --user www-data nextcloud-nextcloud-1 php occ preview:pre-generate
      '';
    };
  };
}
