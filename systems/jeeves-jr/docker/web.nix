{
  virtualisation.oci-containers.containers = {
    arch_mirror = {
      image = "ubuntu/apache2:latest";
      volumes = [
        "/ZFS/Main/Docker/templates/file_server/sites/:/etc/apache2/sites-enabled/"
        "/ZFS/Main/Mirror/:/data"
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
        "/ZFS/Main/Docker/jeeves-jr/haproxy/cloudflare.pem:/etc/ssl/certs/cloudflare.pem"
        "/ZFS/Main/Docker/jeeves-jr/haproxy/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg"
      ];
      dependsOn = [ "arch_mirror" ];
      extraOptions = [ "--network=web" ];
      autoStart = true;
    };
    cloud_flare_tunnel = {
      image = "cloudflare/cloudflared:latest";
      cmd = [
        "tunnel"
        "run"
      ];
      environmentFiles = [ "/ZFS/Main/Docker/jeeves-jr/cloudflare_tunnel.env" ];
      dependsOn = [ "haproxy" ];
      extraOptions = [ "--network=web" ];
      autoStart = true;
    };
  };
}
