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
    description = "incremental pre-generation of previews on nextcloud";
    serviceConfig = {
      Type = "oneshot";
      DynamicUser = "yes";
      Group = "docker";
      ExecStart = [
        ''
          ${pkgs.bash}/bin/bash -c '${pkgs.docker}/bin/docker ps --format "{{.Names}}" | ${pkgs.gnugrep}/bin/grep -q "^nextcloud-nextcloud-1$"'
        ''
        ''
          ${pkgs.docker}/bin/docker exec --user www-data nextcloud-nextcloud-1 php occ preview:pre-generate
        ''
      ];
    };
  };
}
