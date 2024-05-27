{ pkgs, config, ... }:
{
  imports = [
    ./filebrowser.nix
    ./internal.nix
    ./web.nix
  ];

  virtualisation.oci-containers.backend = "docker";

  system.activationScripts.mkVPN =
    let
      docker = config.virtualisation.oci-containers.backend;
      dockerBin = "${pkgs.${docker}}/bin/${docker}";
    in
    ''
      ${dockerBin} network inspect web >/dev/null 2>&1 || ${dockerBin} network create web --subnet 172.100.5.0/16
    '';
}
