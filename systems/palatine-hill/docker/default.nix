{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./archiveteam.nix
    ./nextcloud.nix
    ./postgres.nix
  ];

  virtualisation.oci-containers.backend = "docker";
  virtualisation.docker.daemon.settings.data-root = "/var/lib/docker2";

  # "rlcraft-mc-1 itzg/minecraft-server:java8"
  # "mc-router-mc-router-1 itzg/mc-router"

  # "unifi-controller lscr.io/linuxserver/unifi-network-application:latest"
  # "unifi-20-mongodb-1 mongo:7.0"

  # "restic-grafana-1 grafana/grafana:latest"
  # "restic-prometheus-1 prom/prometheus:latest"
  # "restic-restserver-1 restic/rest-server:latest"

  # "firefly-iii-fidi-1 fireflyiii/data-importer:latest"
  # "firefly-iii-app-1 fireflyiii/core:latest"

  # "haproxy-haproxy-1 haproxy:latest"
  # "calibre-web lscr.io/linuxserver/calibre-web:latest"
  # "glances-glances-1 nicolargo/glances:latest-full"
  # "foundry felddy/foundryvtt:11"

  # "Qbit ghcr.io/linuxserver/qbittorrent:latest"
  # "Qbitvpn binhex/arch-qbittorrentvpn:latest"
}
