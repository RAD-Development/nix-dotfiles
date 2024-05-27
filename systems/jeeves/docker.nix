{
  virtualisation.oci-containers = {
    backend = "docker";
    containers.filebrowser = {
      image = "hurlenko/filebrowser";
      ports = [ "443:8080" ];
      volumes = [
        "/DATA_DIR:/ZFS"
        "/CONFIG_DIR:/ZFS/Media/Docker/filebrowser"
      ];
      environment = [ "FB_BASEURL=/filebrowser" ];
      autoStart = true;
      user = "richie:users";
    };
  };
}
