let
  vars = import ../vars.nix;
in
{
  virtualisation.oci-containers.containers = {
    arch_mirror = {
      image = "ubuntu/apache2:latest";
      volumes = [
        "${../../../users/richie/global/docker_templates}/file_server/sites/:/etc/apache2/sites-enabled/"
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
        "${vars.main_docker}/jeeves-jr/haproxy/cloudflare.pem:/etc/ssl/certs/cloudflare.pem"
        "${./haproxy.cfg}:/usr/local/etc/haproxy/haproxy.cfg"
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
      environmentFiles = [ "${vars.main_docker}/jeeves-jr/cloudflare_tunnel.env" ];
      dependsOn = [ "haproxy" ];
      extraOptions = [ "--network=web" ];
      autoStart = true;
    };
  };
}
