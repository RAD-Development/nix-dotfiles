{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.autopull;

  autopull-type =
    with lib.types;
    attrsOf (
      submodule (
        { name, ... }:
        {
          options = {
            enable = lib.mkEnableOption "autopull repo";

            repo-name = lib.mkOption {
              type = lib.types.str;
              default = name;

              description = "A name for the service which needs to be pulled";
            };

            path = lib.mkOption {
              type = lib.types.path;
              description = "Path that needs to be updated via git pull";
            };

            frequency = lib.mkOption {
              type = lib.types.str;
              description = "systemd-timer compatible time between pulls";
              default = "1h";
            };

            ssh-key = lib.mkOption {
              type = lib.types.str;
              default = "";
              description = "ssh-key used to pull the repository";
            };
          };
        }
      )
    );
in
{
  options = {
    services.autopull = {
      enable = lib.mkEnableOption "autopull";

      repo = lib.mkOption { type = autopull-type; };
    };
  };

  config =
    let
      repos = lib.filterAttrs (_: { enable, ... }: enable) cfg.repo;
    in
    lib.mkIf cfg.enable {
      environment.systemPackages =
        [ pkgs.git ]
        ++ lib.optionals (lib.any (ssh-key: ssh-key != "") (lib.rad-dev.mapGetAttr "ssh-key" repos)) [
          pkgs.openssh
        ];

      systemd.services = lib.mapAttrs' (
        _:
        {
          repo-name,
          ssh-key,
          path,
          ...
        }:
        lib.nameValuePair "autopull@${repo-name}" {
          requires = [ "multi-user.target" ];
          after = [ "multi-user.target" ];
          description = "Pull the latest data for ${repo-name}";
          environment = lib.mkIf (ssh-key != "") {
            GIT_SSH_COMMAND = "${pkgs.openssh}/bin/ssh -i ${ssh-key} -o IdentitiesOnly=yes";
          };
          serviceConfig = {
            Type = "oneshot";
            User = "root";
            WorkingDirectory = path;
            ExecStart = "${pkgs.git}/bin/git pull --all";
          };
        }
      ) repos;

      systemd.timers = lib.mapAttrs' (
        _:
        { repo-name, frequency, ... }:
        lib.nameValuePair "autopull@${repo-name}" {
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnBootSec = frequency;
            OnUnitActiveSec = frequency;
            Unit = "autopull@${repo-name}.service";
          };
        }
      ) repos;
    };
}
