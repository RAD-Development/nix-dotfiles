{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.autopull;

  autopull-type = lib.types.submodule {
    enable = lib.mkEnableOption "autopull for ${cfg.account-name}";

    name = lib.mkOption {
      type = lib.types.str;
      default = config.module._args.name;
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

    triggers-rebuild = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether or not the rebuild service should be triggered after pulling. Note that system.autoUpgrade must be pointed at the same directory as this service if you'd like to use this option.";
    };
  };
in
{
  options = {
    services.autopull = {
      enable = lib.mkEnableOption "autopull";

      repo = lib.mkOption { type = lib.types.attrsOf autopull-type; };
    };
  };

  config =
    let
      repos = lib.filterAttrs (_: { enable, ... }: enable == true) cfg.repo;
    in
    lib.mkIf cfg.enable {
      environment.systemPackages = [
        pkgs.openssh
        pkgs.git
      ];
      systemd.services = lib.mapAttrs' (
        repo:
        {
          name,
          ssh-key,
          triggers-rebuild,
          ...
        }:
        lib.nameValuePair "autopull@${name}" {
          requires = [ "multi-user.target" ];
          wants = lib.optionals (triggers-rebuild) [ "nixos-service.service" ];
          after = [ "multi-user.target" ];
          before = lib.optionals (triggers-rebuild) [ "nixos-upgrade.service" ];
          description = "Pull the latest data for ${name}";
          environment = lib.mkIf (ssh-key != "") {
            GIT_SSH_COMMAND = "${pkgs.openssh}/bin/ssh -i ${ssh-key} -o IdentitiesOnly=yes";
          };
          serviceConfig = {
            Type = "oneshot";
            User = "root";
            WorkingDirectory = cfg.path;
            ExecStart = "${pkgs.git}/bin/git pull --all";
          };
        }
      ) repos;

      systemd.timers."autopull@${cfg.name}" = lib.mapAttrs' (
        repo:
        { name, frequency, ... }:
        lib.nameValuePair "autopull@${name}" {
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnBootSec = cfg.frequency;
            OnUnitActiveSec = cfg.frequency;
            Unit = "autopull@${cfg.name}.service";
          };
        }
      ) repos;
    };
}
