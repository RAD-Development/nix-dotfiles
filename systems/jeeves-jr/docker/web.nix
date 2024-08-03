{ config, ... }:
{
  virtualisation.oci-containers.containers = {
    haproxy = {
      image = "haproxy:latest";
      user = "600:600";
      environment = {
        TZ = "Etc/EST";
      };
      volumes = [
        "${config.sops.secrets."docker/haproxy_cert".path}:/etc/ssl/certs/cloudflare.pem"
        "${./haproxy.cfg}:/usr/local/etc/haproxy/haproxy.cfg"
      ];
      dependsOn = [
        "arch_mirror"
        "uptime_kuma"
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
      environmentFiles = [ config.sops.secrets."docker/cloud_flare_tunnel".path ];
      dependsOn = [ "haproxy" ];
      extraOptions = [ "--network=web" ];
      autoStart = true;
    };
  };
  sops = {
    defaultSopsFile = ../secrets.yaml;
    secrets = {
      "docker/cloud_flare_tunnel".owner = "docker-service";
      "docker/haproxy_cert".owner = "docker-service";
    };
  };

}
