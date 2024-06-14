{ ... }:

{
  virtualisation.docker.daemon.settings.data-root = "/var/lib/docker2";

  users.users.docker-service = {
    isSystemUser = true;
    extraGroups = [ "docker" ];
    uid = 600;
  };
}
