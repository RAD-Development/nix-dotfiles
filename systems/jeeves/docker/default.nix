{
  imports = [
    ./filebrowser.nix
    ./internal.nix
    ./web.nix
    ./postgresql.nix
    ./uptime_kuma.nix
  ];

  virtualisation.oci-containers.backend = "docker";
}
