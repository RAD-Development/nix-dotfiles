{
  config,
  lib,
  pkgs,
  ...
}:

let
  containers = {
    archiveteam-imgur = {
      image = "imgur-grab";
      scale = 1;
    };
    #archiveteam-telegram = {
    #  image = "telegram-grab";
    #  scale = 3;
    #};
    #archiveteam-reddit = {
    #  image = "reddit-grab";
    #  scale = 1;
    #};
    #archiveteam-dpreview = {
    #  image = "dpreview-grab";
    #  scale = 0;
    #};
    #archiveteam-issuu = {
    #  image = "issuu-grab";
    #  scale = 0;
    #};
    #archiveteam-urls = {
    #  image = "urls-grab";
    #  scale = 2;
    #};
    #archiveteam-urlteam = {
    #  image = "terroroftinytown-client-grab";
    #  scale = 2;
    #};
    #archiveteam-mediafire = {
    #  image = "mediafire-grab";
    #  scale = 1;
    #};
    #archiveteam-github = {
    #  image = "github-grab";
    #  scale = 1;
    #};
    #archiveteam-lineblog = {
    #  image = "lineblog-grab";
    #  scale = 0;
    #};
    #archiveteam-banciyuan = {
    #  image = "banciyuan-grab";
    #  scale = 0;
    #};
    #archiveteam-wysp = {
    #  image = "wysp-grab";
    #  scale = 0;
    #};
    #archiveteam-xuite = {
    #  image = "xuite-grab";
    #  scale = 0;
    #};
    #archiveteam-gfycat = {
    #  image = "gfycat-grab";
    #  scale = 0;
    #};
    #archiveteam-skyblog = {
    #  image = "skyblog-grab";
    #  scale = 0;
    #};
    #archiveteam-zowa = {
    #  image = "zowa-grab";
    #  scale = 0;
    #};
    #archiveteam-blogger = {
    #  image = "blogger-grab";
    #  scale = 0;
    #};
    #archiveteam-vbox7 = {
    #  image = "vbox7-grab";
    #  scale = 0;
    #};
    #archiveteam-pastebin = {
    #  image = "pastebin-grab";
    #  scale = 1;
    #};
    #archiveteam-youtube = {
    #  image = "youtube-grab";
    #  scale = 1;
    #};
    #archiveteam-deviantart = {
    #  image = "deviantart-grab";
    #  scale = 1;
    #};
    #archiveteam-postnews = {
    #  image = "postnews-grab";
    #  scale = 1;
    #};
  };
  container-spec = container: {
    image = "atdr.meo.ws/archiveteam/${container}";
    extraOptions = [ "--stop-signal=SIGINT" ];
    labels = {
      "com.centurylinklabs.watchtower.enable" = "true";
      "com.centurylinklabs.watchtower.scope" = "archiveteam";
    };
    log-driver = "local";
    cmd = lib.splitString " " "--concurrent 6 AmAnd0";

  };
in
{
  virtualisation.oci-containers.containers =
    (lib.rad-dev.createTemplatedContainers containers container-spec)
    // {
      archiveteam-watchtower = {
        image = "containrrr/watchtower:latest";
        labels = {
          "com.centurylinklabs.watchtower.enable" = "true";
          "com.centurylinklabs.watchtower.scope" = "archiveteam";
        };
        volumes = [ "/var/run/docker.sock:/var/run/docker.sock" ];
        log-driver = "local";
        cmd = lib.splitString " " "--label-enable --cleanup --interval 600";
      };
    };
}
