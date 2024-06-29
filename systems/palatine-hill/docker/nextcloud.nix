{
  config,
  lib,
  pkgs,
  ...
}:

let
  nextcloud-image = import ./nextcloud-image.nix { inherit pkgs; };
in
{
  virtualisation.oci-containers.containers = {
    nextcloud = {
      image = "nextcloud-custom:latest";
      imageFile = nextcloud-image;
      hostname = "nextcloud";
      ports = [
        "9999:80"

      ];
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
    };
  };
}
