{
  imports = [
    ./filebrowser.nix
    ./internal.nix
    ./web.nix
    ./postgresql.nix
  ];

  virtualisation.oci-containers.backend = "docker";
}
