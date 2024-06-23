{
  config,
  lib,
  pkgs,
  ...
}:

let
  containers = {
    imgur = {
      image = "imgur-grab";
      scale = 1;
    };
    telegram = {
      image = "telegram-grab";
      scale = 3;
    };
    reddit = {
      image = "reddit-grab";
      scale = 1;
    };
    dpreview = {
      image = "dpreview-grab";
      scale = 0;
    };
    issuu = {
      image = "issuu-grab";
      scale = 0;
    };
    urls = {
      image = "urls-grab";
      scale = 2;
    };
    urlteam = {
      image = "terroroftinytown-client-grab";
      scale = 2;
    };
    mediafire = {
      image = "mediafire-grab";
      scale = 1;
    };
    github = {
      image = "github-grab";
      scale = 1;
    };
    lineblog = {
      image = "lineblog-grab";
      scale = 0;
    };
    banciyuan = {
      image = "banciyuan-grab";
      scale = 0;
    };
    wysp = {
      image = "wysp-grab";
      scale = 0;
    };
    xuite = {
      image = "xuite-grab";
      scale = 0;
    };
    gfycat = {
      image = "gfycat-grab";
      scale = 0;
    };
    skyblog = {
      image = "skyblog-grab";
      scale = 0;
    };
    zowa = {
      image = "zowa-grab";
      scale = 0;
    };
    blogger = {
      image = "blogger-grab";
      scale = 0;
    };
    vbox7 = {
      image = "vbox7-grab";
      scale = 0;
    };
    pastebin = {
      image = "pastebin-grab";
      scale = 1;
    };
    youtube = {
      image = "youtube-grab";
      scale = 1;
    };
    deviantart = {
      image = "deviantart-grab";
      scale = 1;
    };
  };
  container-spec = container: {
    image = "atdr.meo.ws/archiveteam/${container}";
    extraOptions = [
      "--stop-signal=SIGINT"
      "--stop-timeout=1800"
    ];
    labels = {
      "com.centurylinklabs.watchtower.enable" = "true";
      "com.centurylinklabs.watchtower.scope" = "archiveteam";
    };
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
        cmd = lib.splitString " " "--label-enable --cleanup --interval 600";
      };
    };
}
