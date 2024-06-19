{
  virtualisation.oci-containers.containers.filebrowser = {
    image = "hurlenko/filebrowser";
    ports = [ "8080:8080" ];
    volumes = [
      "/ZFS:/data"
      "/ZFS/media/Docker/filebrowser:/config"
    ];
    autoStart = true;
    user = "nobody:users";
  };
}
