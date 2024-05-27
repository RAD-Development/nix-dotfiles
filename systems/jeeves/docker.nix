{
  virtualisation.oci-containers = {
    backend = "docker";
    containers.filebrowser = {
      image = "hurlenko/filebrowser";
      ports = [ "8080:8080" ];
      volumes = [
        "/ZFS:/data"
        "/ZFS/Media/Docker/filebrowser:/config"
      ];
      autoStart = true;
      user = "nobody:users";
    };
  };
}
