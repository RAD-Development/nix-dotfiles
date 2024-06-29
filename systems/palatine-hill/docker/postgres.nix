{
  config,
  lib,
  pkgs,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    postgres = {
      image = "postgres:16";
      user = "600:600";
      volumes = [
        "/ZFS/ZFS-primary/db/postgresql/primary_new:/var/lib/postgresql/data"
        "/ZFS/ZFS-primary/db/postgresql/pg_archives:/opt/pg_archives"
      ];
      log-driver = "local";
      extraOptions = [
        "--network=postgres-net"
        "--health-cmd='pg_isready -U firefly'"
        "--health-interval=1s"
        "--health-timeout=5s"
        "--health-retries=15"
        "--shm-size=1gb"
      ];
      environmentFiles = [ config.sops.secrets."docker/pg".path ];
      restart = "always";
    };

    postgres-secondary = {
      image = "postgres:16";
      user = "600:600";
      volumes = [
        "/ZFS/ZFS-primary/db/postgresql/primary_new:/var/lib/postgresql/data"
        "/ZFS/ZFS-primary/db/postgresql/pg_archives:/opt/pg_archives"
      ];
      log-driver = "local";
      extraOptions = [
        "--network=postgres-net"
        "--health-cmd='pg_isready -U firefly'"
        "--health-interval=1s"
        "--health-timeout=5s"
        "--health-retries=15"
        "--shm-size=1gb"
      ];
      environmentFiles = [ config.sops.secrets."docker/pg".path ];
      restart = "always";
    };

    postgres-adminer = {
      image = "adminer/latest";
      user = "600:600";
      restart = "always";
      ports = [ "4191:8080" ];
      dependsOn = [ "postgres" ];
      extraOptions = [ "--network=postgres-net" ];
    };
  };
  sops = {
    defaultSopsFile = ../secrets.yaml;
    secrets = {
      "docker/pg".owner = "docker-service";
    };
  };

}
