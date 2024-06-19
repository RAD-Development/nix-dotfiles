{
  virtualisation.oci-containers.containers = {
    grafana = {
      image = "grafana/grafana-enterprise";
      volumes = [ "/ZFS/Media/Docker/Docker/Storage/grafana:/var/lib/grafana" ];
      user = "998:998";
      extraOptions = [ "--network=web" ];
      autoStart = true;
    };
    dnd_file_server = {
      image = "ubuntu/apache2:latest";
      volumes = [
        "/ZFS/Media/Docker/Docker/templates/file_server/sites/:/etc/apache2/sites-enabled/"
        "/ZFS/Storage/Main/Table_Top/:/data"
      ];
      extraOptions = [ "--network=web" ];
      autoStart = true;
    };
    arch_mirror = {
      image = "ubuntu/apache2:latest";
      volumes = [
        "/ZFS/Media/Docker/Docker/templates/file_server/sites/:/etc/apache2/sites-enabled/"
        "/ZFS/Media/Mirror/:/data"
      ];
      ports = [ "800:80" ];
      extraOptions = [ "--network=web" ];
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
      extraOptions = [ "--network=web" ];
      autoStart = true;
    };
    cloud_flare_tunnel = {
      image = "cloudflare/cloudflared:latest";
      cmd = [
        "tunnel"
        "run"
      ];
      environmentFiles = [ "/ZFS/Media/Docker/Docker/jeeves/web/cloudflare_tunnel.env" ];
      dependsOn = [ "haproxy" ];
      extraOptions = [ "--network=web" ];
      autoStart = true;
    };
  overseerr = {
    image = "lscr.io/linuxserver/overseerr";
    environment = {
      PUID = "998";
      PGID = "100";
      TZ = "America/New_York";
    };
    volumes = [ "/ZFS/Media/Docker/Docker/Storage/overseerr:/config" ];
    # commenting this out for now for setup purposes.
    # TODO: remove ports later since this is going through web
    # ports = [ "5055:5055" ]; # Web UI port
    dependsOn = [
      "radarr"
      "sonarr"
    ];
    extraOptions = [ "--network=web" ];
    autoStart = true;
  };
  };
}
