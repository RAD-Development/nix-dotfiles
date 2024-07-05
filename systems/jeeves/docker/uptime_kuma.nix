let
  vars = import ../vars.nix;
in
{
  virtualisation.oci-containers.containers = {
    uptime_kuma = {
      image = "louislam/uptime-kuma:latest";
      volumes = [
        "${vars.media_docker_configs}/uptime_kuma:/app/data"
        "/var/run/docker.sock:/var/run/docker.sock"
      ];
      extraOptions = [ "--network=web" ];
      autoStart = true;
    };
  };
}
