{ config, ... }:
let
  vars = import ../vars.nix;
in
{
  virtualisation.oci-containers.containers = {
    grafana = {
      image = "grafana/grafana-enterprise:latest";
      volumes = [ "${vars.media_docker_configs}/grafana:/var/lib/grafana" ];
      user = "600:600";
      extraOptions = [ "--network=web" ];
      autoStart = true;
    };
    dnd_file_server = {
      image = "ubuntu/apache2:latest";
      volumes = [
        "${vars.media_docker_templates}/file_server/sites/:/etc/apache2/sites-enabled/"
        "${vars.storage_main}/Table_Top/:/data"
      ];
      extraOptions = [ "--network=web" ];
      autoStart = true;
    };
    arch_mirror = {
      image = "ubuntu/apache2:latest";
      volumes = [
        "${vars.media_docker_templates}/file_server/sites/:/etc/apache2/sites-enabled/"
        "${vars.media_mirror}:/data"
      ];
      ports = [ "800:80" ];
      extraOptions = [ "--network=web" ];
      autoStart = true;
    };
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
        "dnd_file_server"
        "filebrowser"
        "grafana"
        "uptime_kuma"
      ];
      extraOptions = [ "--network=web" ];
      autoStart = true;
    };
    cloud_flare_tunnel = {
      image = "cloudflare/cloudflared:latest";
      user = "600:600";
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
