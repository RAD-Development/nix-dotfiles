{
  config,
  lib,
  pkgs,
  ...
}:

let
  nextcloud-image = import ./nextcloud-image { inherit pkgs; };
in
{
  virtualisation.oci-containers.containers = {
    nextcloud = {
      image = "nextcloud-custom:latest";
      imageFile = nextcloud-image;
      hostname = "nextcloud";
      ports = [ "9999:80" ];
      volumes = [
        "/ZFS/ZFS-primary/nextcloud/nc_data:/var/www/html:z"
        "/ZFS/ZFS-primary/nextcloud/nc_php:/usr/local/etc/php"
        "/ZFS/ZFS-primary/nextcloud/nc_prehooks:/docker-entrypoint-hooks.d/before-starting"
      ];
      extraOptions = [
        "--restart=unless-stopped"
        "--network=haproxy-net"
        "--network=postgres-net"
        "--network=nextcloud_default"
      ];
      dependsOn = [ "redis" ];
      environmentFiles = [ config.sops.secrets."docker/nextcloud".path ];
    };
    redis = {
      image = "redis:latest";
      extraOptions = [ "--restart=unless-stopped" ];
      volumes = [ "${config.sops.secrets."docker/redis".path}:/usr/local/etc/redis/redis.conf" ];
      cmd = [
        "redis-server"
        config.sops.secrets."docker/redis".path
      ];
    };
    go-vod = {
      image = "radialapps/go-vod";
      dependsOn = [ "nextcloud" ];
      environment = {
        NEXTCLOUD_HOST = "https://nextcloud.alicehuston.xyz";
      };
      volumes = [ "/ZFS/ZFS-primary/nextcloud/nc_data:/var/www/html:ro" ];
      extraOptions = [
        "--restart=always"
        "--device=/dev/dri:/dev/dri"
      ];
    };
  };

  sops = {
    defaultSopsFile = ../secrets.yaml;
    secrets = {
      "docker/redis".owner = "docker-service";
      "docker/nextcloud".owner = "docker-service";
    };
  };
}
