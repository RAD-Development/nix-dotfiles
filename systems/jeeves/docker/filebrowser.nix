{
  virtualisation.oci-containers.containers.filebrowser = {
    image = "hurlenko/filebrowser";
    extraOptions = [ "--network=web" ];
    volumes = [
      "/ZFS:/data"
      "/zfs/media/docker/configs/filebrowser:/config"
    ];
    autoStart = true;
    user = "richie:users";
  };
}
