{
  virtualisation.oci-containers.containers.filebrowser = {
    image = "hurlenko/filebrowser";
    extraOptions = [ "--network=web" ];
    volumes = [
      "/zfs:/data"
      "/zfs/media/docker/configs/filebrowser:/config"
    ];
    autoStart = true;
    user = "1000:users";
  };
}
