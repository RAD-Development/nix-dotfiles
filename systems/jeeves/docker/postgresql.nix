{ config, ... }:
let
  vars = import ../vars.nix;
in
{
  users = {
    users.postgres = {
      isSystemUser = true;
      group = "postgres";
      uid = 999;
    };
    groups.postgres = {
      gid = 999;
    };
  };

  virtualisation.oci-containers.containers = {
    postgres = {
      image = "postgres:16";
      ports = [ "5432:5432" ];
      volumes = [ "${vars.media_database}/postgres:/var/lib/postgresql/data" ];
      environment = {
        POSTGRES_USER = "admin";
        POSTGRES_DB = "archive";
        POSTGRES_INITDB_ARGS = "--auth-host=scram-sha-256";
      };
      environmentFiles = [ config.sops.secrets."docker/postgres".path ];
      autoStart = true;
      user = "postgres:postgres";
    };
  };

  sops = {
    defaultSopsFile = ../secrets.yaml;
    secrets."docker/postgres".owner = "postgres";
  };
}
