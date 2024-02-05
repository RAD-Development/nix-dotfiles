{ config, lib, pkgs, ... }:

let cfg = config.services.autopull;
in {
  options = {
    services.autopull = {
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
        default = "1h";
      };

      ssh-key = lib.mkOption {
        type = lib.types.str;
        description = "ssh-key used to pull the repository";
      };

      triggersRebuild = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether or not the rebuild service should be triggered after pulling. Note that system.autoUpgrade must be pointed at the same directory as this service if you'd like to use this option.";
      };
    };
  };

  config = lib.mkIf (cfg.enable && !(builtins.isNull cfg.path)) {
    environment.systemPackages = [ pkgs.openssh pkgs.git ];
    systemd.services."autopull@${cfg.name}" = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      description = "Pull the latest data for ${cfg.name}";
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        WorkingDirectory = cfg.path;
        Environment = lib.mkIf (cfg.ssh-key != "") "GIT_SSH_COMMAND=${pkgs.openssh}/bin/ssh -i ${cfg.ssh-key} -o IdentitiesOnly=yes";
        ExecStart = "${pkgs.git}/bin/git pull --all";
        Before = "nixos-upgrade.service";
        Wants = "nixos-upgrade.service";
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
