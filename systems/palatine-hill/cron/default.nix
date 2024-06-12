{
  config,
  lib,
  pkgs,
  ...
}:

{
  services.cron.enable = true;
  services.cron.cronFiles = [ /etc/rad-dev/nextcloud-cron ];
  environment.etc.nextcloud-cron = {
    text = ''
      */10 * * * * docker ps --format "{{.Names}}" | grep -q "^nextcloud-nextcloud-1$" && docker exec --user www-data nextcloud-nextcloud-1 php occ preview:pre-generate
    '';
    target = "rad-dev/nextcloud-cron";
  };
}
