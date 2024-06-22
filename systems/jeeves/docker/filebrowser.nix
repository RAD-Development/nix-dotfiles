{
  virtualisation.oci-containers.containers.filebrowser = {
    image = "hurlenko/filebrowser";
    extraOptions = [ "--network=web" ];
    ports = [ "8080:8080" ];
    volumes = [
      "/ZFS:/data"
      "/zfs/media/docker/configs/filebrowser:/config"
    ];
    autoStart = true;
    user = "1000:users";
  };
}
