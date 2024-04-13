{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.rad-dot.docker-deploy;
in
{
  options.rad-dot.service-account = {
    enable = lib.mkEnableOption "docker-deploy";

    account-name = lib.mkOption {
      type = lib.types.str;
      default = "docker-deploy";
      description = "account name to be used for the service account";
    };

    pub-ssh-key = lib.mkOption {
      type = lib.types.str;
      default = /etc/docker-deploy/.ssh/id_ed25519;
      description = "Public ssh-key used for deployments";
    };
  };

  config = lib.mkIf (cfg.enable) {

  };
}
