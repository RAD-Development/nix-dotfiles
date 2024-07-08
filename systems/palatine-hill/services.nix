{
  config,
  inputs,
  pkgs,
  ...
}:
{
  systemd = {
    services.startup_validation = {
      wantedBy = [ "multi-user.target" ];
      description = "validates startup";
      path = [ pkgs.zfs ];
      serviceConfig = {
        Type = "oneshot";
        Environment = config.sops.secrets."server-validation/webhook".path;
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
  sops = {
    defaultSopsFile = ./secrets.yaml;
    secrets."server-validation/webhook".owner = "root";
  };
}
