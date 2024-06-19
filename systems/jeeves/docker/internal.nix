{
  virtualisation.oci-containers.containers = {
    qbit = {
      image = "ghcr.io/linuxserver/qbittorrent";
      ports = [
        "6881:6881"
        "6881:6881/udp"
        "8082:8082"
        "29432:29432"
      ];
      volumes = [
        "/ZFS/media/Docker/Docker/Storage/qbit:/config"
        "/ZFS/torrenting/Qbit/:/data"
      ];
      environment = {
        PUID = "998";
        PGID = "100";
        TZ = "America/New_York";
        WEBUI_PORT = "8082";
      };
      autoStart = true;
    };
    qbitvpn = {
      image = "binhex/arch-qbittorrentvpn";
      ports = [
        "6882:6881"
        "6882:6881/udp"
        "8081:8081"
        "8118:8118"
      ];
      volumes = [
        "/ZFS/media/Docker/Docker/Storage/qbitvpn:/config"
        "/ZFS/torrenting/QbitVPN/:/data"
        "/etc/localtime:/etc/localtime:ro"
      ];
      environment = {
        WEBUI_PORT = "8081";
        PUID = "998";
        PGID = "100";
        VPN_ENABLED = "yes";
        VPN_CLIENT = "openvpn";
        STRICT_PORT_FORWARD = "yes";
        ENABLE_PRIVOXY = "yes";
        LAN_NETWORK = "192.168.90.0/24";
        NAME_SERVERS = "192.168.90.0";
        UMASK = "000";
        DEBUG = "false";
        DELUGE_DAEMON_LOG_LEVEL = "debug";
        DELUGE_WEB_LOG_LEVEL = "debug";
      };
      environmentFiles = [ "/ZFS/media/Docker/Docker/jeeves/internal/qbitvpn.env" ];
      autoStart = true;
    };
    prowlarr = {
      image = "ghcr.io/linuxserver/prowlarr";
      environment = {
        PUID = "998";
        PGID = "100";
        TZ = "America/New_York";
      };
      volumes = [ "/ZFS/media/Docker/Docker/Storage/prowlarr:/config" ];
      autoStart = true;
    };
    radarr = {
      image = "ghcr.io/linuxserver/radarr";
      environment = {
        PUID = "998";
        PGID = "100";
        TZ = "America/New_York";
      };
      volumes = [
        "/ZFS/media/Docker/Docker/Storage/radarr:/config"
        "/ZFS/storage/Plex/Movies:/movies"
        "/ZFS/torrenting/QbitVPN:/data"
      ];
      autoStart = true;
    };
    sonarr = {
      image = "ghcr.io/linuxserver/sonarr";
      environment = {
        PUID = "998";
        PGID = "100";
        TZ = "America/New_York";
      };
      volumes = [
        "/ZFS/media/Docker/Docker/Storage/sonarr:/config"
        "/ZFS/storage/Plex/TV:/tv"
        "/ZFS/torrenting/QbitVPN:/data"
      ];
      autoStart = true;
    };
  };
}
