{
  imports = [
    ./filebrowser.nix
    ./internal.nix
  ];

  virtualisation.oci-containers.backend = "docker";
}
