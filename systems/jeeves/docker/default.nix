{
  imports = [
    ./filebrowser.nix
    ./internal.nix
    ./web.nix
    ./postgresql.nix
  ];

  users = {
    users.docker-service = {
      isSystemUser = true;
      group = "docker-service";
      extraGroups = [ "docker" ];
      uid = 600;
    };
    groups.docker-service = {
      gid = 600;
    };
  };

  virtualisation.oci-containers.backend = "docker";
}
