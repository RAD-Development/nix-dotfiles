{
  virtualisation.oci-containers.containers = {
    grafana = {
      image = "grafana/grafana-enterprise";
      volumes = [ "/zfs/media/docker/configs/grafana:/var/lib/grafana" ];
      user = "998:998";
      extraOptions = [ "--network=web" ];
      autoStart = true;
    };
    dnd_file_server = {
      image = "ubuntu/apache2:latest";
      volumes = [
        "/zfs/media/docker/templates/file_server/sites/:/etc/apache2/sites-enabled/"
        "/zfs/storage/main/Table_Top/:/data"
      ];
      extraOptions = [ "--network=web" ];
      autoStart = true;
    };
    arch_mirror = {
      image = "ubuntu/apache2:latest";
      volumes = [
        "/zfs/media/docker/templates/file_server/sites/:/etc/apache2/sites-enabled/"
        "/zfs/media/mirror/:/data"
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
        "/zfs/media/docker/cloudflare.pem:/etc/ssl/certs/cloudflare.pem"
        "/zfs/media/docker/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg"
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
      environmentFiles = [ "/zfs/media/docker/cloudflare_tunnel.env" ];
      dependsOn = [ "haproxy" ];
      extraOptions = [ "--network=web" ];
      autoStart = true;
    };
  };
}
