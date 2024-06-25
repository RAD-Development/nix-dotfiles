{ config, ... }:

let
  base_path = "/ZFS/ZFS-primary/minio";
in
{
  services.minio = {
    enable = true;
    rootCredentialsFile = config.sops.secrets."minio/credentials".path;
    listenAddress = ":8500";
    dataDir = [ "${base_path}/data" ];
    consoleAddress = ":8501";
    configDir = "${base_path}/config";
  };

  sops = {
    defaultSopsFile = ./secrets.yaml;
    secrets = {
      "minio/credentials" = {
        owner = "minio";
      };
    };
  };
}
