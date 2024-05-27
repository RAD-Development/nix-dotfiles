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
        "/ZFS/Media/Docker/Docker/Storage/qbit:/config"
        "/ZFS/Torenting/Qbit/:/data"
      ];
      environment = {
        PUID = "998";
        PGID = "100";
        TZ = "America/New_York";
        WEBUI_PORT = "8082";
      };
      autoStart = true;
    };
    grafana = {
      image = "grafana/grafana-enterprise";
      volumes = [ "/ZFS/Media/Docker/Docker/Storage/grafana:/var/lib/grafana" ];
      user = "998:998";
      autoStart = true;
    };
    dnd_file_server = {
      image = "ubuntu/apache2:latest";
      volumes = [
        "/ZFS/Media/Docker/Docker/templates/file_server/sites/:/etc/apache2/sites-enabled/"
        "/ZFS/Storage/Main/Table_Top/:/data"
      ];
      autoStart = true;
    };
    arch_mirror = {
      image = "ubuntu/apache2:latest";
      volumes = [
        "/ZFS/Media/Docker/Docker/templates/file_server/sites/:/etc/apache2/sites-enabled/"
        "/ZFS/Media/Mirror/:/data"
      ];
      ports = [ "800:80" ];
      autoStart = true;
    };
    haproxy = {
      image = "haproxy:latest";
      user = "998:998";
      environment = {
        TZ = "Etc/EST";
      };
      volumes = [
        "/ZFS/Media/Docker/Docker/jeeves/web/haproxy/cloudflare.pem:/etc/ssl/certs/cloudflare.pem"
        "/ZFS/Media/Docker/Docker/jeeves/web/haproxy/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg"
        "/ZFS/Media/Docker/Docker/jeeves/web/haproxy/API:/run/haproxy/"
      ];
      dependsOn = [
        "grafana"
        "arch_mirror"
        "dnd_file_server"
      ];
      autoStart = true;
    };
    cloud_flare_tunnel = {
      image = "cloudflare/cloudflared:latest";
      cmd = "tunnel run";
      environmentFiles = [ "/ZFS/Media/Docker/Docker/jeeves/web/cloudflare_tunnel.env" ];
      dependsOn = [ "haproxy" ];
      autoStart = true;
    };
  };
}
