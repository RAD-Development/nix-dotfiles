{ inputs, pkgs, ... }:
let
  vars = import ./vars.nix;
in
{
  virtualisation.oci-containers.containers.arch_mirror = {
    image = "ubuntu/apache2:latest";
    volumes = [
      "${../../users/richie/global/docker_templates}/file_server/sites/:/etc/apache2/sites-enabled/"
      "${vars.main_mirror}:/data"
    ];
    ports = [ "800:80" ];
    extraOptions = [ "--network=web" ];
    autoStart = true;
  };

  systemd.services.sync_mirror = {
    requires = [ "network-online.target" ];
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    description = "validates startup";
    path = [ pkgs.rsync ];
    serviceConfig = {
      Environment = "MIRROR_DIR=${vars.main_mirror}/archlinux/";
      Type = "simple";
      ExecStart = "${inputs.arch_mirror.packages.x86_64-linux.default}/bin/sync_mirror";
    };
  };
}
