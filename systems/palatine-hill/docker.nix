{ ... }:

{
  virtualisation.docker.daemon.settings.data-root = "/var/lib/docker2";

  users = {
    users.docker-service = {
      isSystemUser = true;
      group = "docker-service";
      extraGroups = [ "docker" ];
      uid = 600;
    };
    groups.docker-service = { };
  };
}
