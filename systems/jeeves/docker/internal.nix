{ config, ... }:
let
  vars = import ../vars.nix;
in
{
  virtualisation.oci-containers.containers = {
    qbit = {
      image = "ghcr.io/linuxserver/qbittorrent:latest";
      ports = [
        "6881:6881"
        "6881:6881/udp"
        "8082:8082"
        "29432:29432"
      ];
      volumes = [
        "${vars.media_docker_configs}/qbit:/config"
        "${vars.torrenting_qbit}:/data"
      ];
      environment = {
        PUID = "600";
        PGID = "100";
        TZ = "America/New_York";
        WEBUI_PORT = "8082";
      };
      autoStart = true;
    };
    qbitvpn = {
      image = "binhex/arch-qbittorrentvpn:latest";
      extraOptions = [ "--cap-add=NET_ADMIN" ];
      ports = [
        "6882:6881"
        "6882:6881/udp"
        "8081:8081"
        "8118:8118"
      ];
      volumes = [
        "${vars.media_docker_configs}/qbitvpn:/config"
        "${vars.torrenting_qbitvpn}:/data"
        "/etc/localtime:/etc/localtime:ro"
      ];
      environment = {
        WEBUI_PORT = "8081";
        PUID = "600";
        PGID = "100";
        VPN_ENABLED = "yes";
        VPN_CLIENT = "openvpn";
        STRICT_PORT_FORWARD = "yes";
        ENABLE_PRIVOXY = "yes";
        LAN_NETWORK = "192.168.90.0/24";
        NAME_SERVERS = "1.1.1.1,1.0.0.1";
        UMASK = "000";
        DEBUG = "false";
        DELUGE_DAEMON_LOG_LEVEL = "debug";
        DELUGE_WEB_LOG_LEVEL = "debug";
      };
      environmentFiles = [ config.sops.secrets."docker/qbit_vpn".path ];
      autoStart = true;
    };
    bazarr = {
      image = "ghcr.io/linuxserver/bazarr:latest";
      ports = [ "6767:6767" ];
      environment = {
        PUID = "600";
        PGID = "100";
        TZ = "America/New_York";
      };
      volumes = [
        "${vars.media_docker_configs}/bazarr:/config"
        "${vars.storage_plex}/movies:/movies"
        "${vars.storage_plex}/tv:/tv"
      ];
      autoStart = true;
    };
    prowlarr = {
      image = "ghcr.io/linuxserver/prowlarr:latest";
      ports = [ "9696:9696" ];
      environment = {
        PUID = "600";
        PGID = "100";
        TZ = "America/New_York";
      };
      volumes = [ "${vars.media_docker_configs}/prowlarr:/config" ];
      autoStart = true;
    };
    radarr = {
      image = "ghcr.io/linuxserver/radarr:latest";
      ports = [ "7878:7878" ];
      environment = {
        PUID = "600";
        PGID = "100";
        TZ = "America/New_York";
      };
      volumes = [
        "${vars.media_docker_configs}/radarr:/config"
        "${vars.storage_plex}/movies:/movies"
        "${vars.torrenting_qbitvpn}:/data"
      ];
      autoStart = true;
    };
    sonarr = {
      image = "ghcr.io/linuxserver/sonarr:latest";
      ports = [ "8989:8989" ];
      environment = {
        PUID = "600";
        PGID = "100";
        TZ = "America/New_York";
      };
      volumes = [
        "${vars.media_docker_configs}/sonarr:/config"
        "${vars.storage_plex}/tv:/tv"
        "${vars.torrenting_qbitvpn}:/data"
      ];
      autoStart = true;
    };
    whisper = {
      image = "ghcr.io/linuxserver/faster-whisper:latest";
      ports = [ "10300:10300" ];
      environment = {
        PUID = "600";
        PGID = "100";
        TZ = "America/New_York";
        WHISPER_MODEL = "tiny-int8";
        WHISPER_LANG = "en";
        WHISPER_BEAM = "1";
      };
      volumes = [ "${vars.media_docker_configs}/whisper:/config" ];
      autoStart = true;
    };
  };
  sops = {
    defaultSopsFile = ../secrets.yaml;
    secrets."docker/qbit_vpn".owner = "docker-service";
  };
}
