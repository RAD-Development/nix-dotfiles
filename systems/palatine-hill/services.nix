{ inputs, ... }:
{
  systemd = {
    services.startup_validation = {
      wantedBy = [ "multi-user.target" ];
      description = "validates startup";
      serviceConfig = {
        Type = "oneshot";
        Environment = "WEBHOOK_URL=test";
        ExecStart = "${inputs.server_tools.packages.x86_64-linux.default}/bin/validate_palatine_hill";
      };
    };
    timers.startup_validation = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "10min";
        Unit = "startup_validation.service";
      };
    };
  };
}
