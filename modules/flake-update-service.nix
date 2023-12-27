{ config, lib, ... }:

let
  cfg = config.services.autopull;
in
{
  options = {
    services.autopull =  {
      enable = lib.mkEnableOption "autopull";
      name = lib.mkOption {
        type = lib.types.str;
        default = "dotfiles";
        description = "A name for the service which needs to be pulled";
      };
      path = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "Path that needs to be updated via git pull";
      };
      frequency = lib.mkOption {
        type = lib.types.str;
        description = "systemd-timer compatible time between pulls";
        default = "6h";
      };
    };
  };

  # implementation
  config = lib.mkIf (cfg.enable && !(builtins.isNull cfg.path)){
    systemd.services."autopull@${cfg.name}" = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      description = "Pull the latest data for ${cfg.name}";
      serviceConfig = {
        Type = "oneshot";
        # TODO: See how we can migrate this to DynamicUser=yes instead
        User = "root";
        WorkingDirectory = cfg.path;
        ExecStart = "git pull";
      };
    };
    systemd.timers."autopull@${cfg.name}" = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = cfg.frequency;
        OnUnitActiveSec = cfg.frequency;
        Unit = "autopull@${cfg.name}.service";
      };
    };
  };
}
