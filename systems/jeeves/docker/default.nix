{
  imports = [
    ./filebrowser.nix
    ./internal.nix
    ./web.nix
  ];

  virtualisation.oci-containers.backend = "docker";
}
