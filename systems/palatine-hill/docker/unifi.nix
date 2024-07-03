{
  config,
  lib,
  pkgs,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    unifi-controller = {
      image = "lscr.io/linuxserver/unifi-network-application:latest";
      volumes = [ "/ZFS/ZFS-primary/docker/unifi-2.0/config:/config" ];
      log-driver = "local";
      dependsOn = [ "mongodb" ];
      extraOptions = [ "--restart=unless-stopped" ];
      ports = [
        "8443:8443"
        "3478:3478/udp"
        "10001:10001/udp"
        "8080:8080"
        "1900:1900/udp" # optional
        "8843:8843" # optional
        "8880:8880" # optional
        "6789:6789" # optional
        "5514:5514/udp" # optional
      ];
      environment = {
        PUID = "1000";
        PGID = "100";
        TZ = "America/New_York";
        MEM_LIMIT = "1024"; # optional
        MEM_STARTUP = "1024"; # optional
        MONGO_USER = "unifi";
        MONGO_HOST = "mongodb";
        MONGO_PORT = "27017";
        MONGO_DBNAME = "unifi";
      };
      environmentFiles = [ config.sops.secrets."docker/unifi".path ];
    };

    mongodb = {
      image = "docker.io/mongo:7.0";
      environment = {
        PUID = "1000";
        PGID = "100";
        TZ = "America/New_York";
      };
      extraOptions = [ "--restart=unless-stopped" ];
      volumes = [
        "/ZFS/ZFS-primary/db/mongo/unifi:/data/db"
        "/ZFS/ZFS-primary/docker/unifi-2.0/init-mongo.js:/docker-entrypoint-initdb.d/init-mongo.js:ro"
      ];
    };
  };
  sops = {
    defaultSopsFile = ../secrets.yaml;
    secrets = {
      "docker/unifi".owner = "docker-service";
    };
  };

}
