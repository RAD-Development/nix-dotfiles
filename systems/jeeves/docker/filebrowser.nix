let
  vars = import ../vars.nix;
in
{
  virtualisation.oci-containers.containers.filebrowser = {
    image = "hurlenko/filebrowser:latest";
    extraOptions = [ "--network=web" ];
    volumes = [
      "/zfs:/data"
      "${vars.media_docker_configs}/filebrowser:/config"
    ];
    autoStart = true;
    user = "1000:users";
  };
}
