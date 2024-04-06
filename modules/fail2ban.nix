{
  config,
  lib,
  libS,
  ...
}:

let
  cfg = config.services.fail2ban;
in
{
  options.services.fail2ban.recommendedDefaults = libS.mkOpinionatedOption "use fail2ban with recommended defaults";

  config.services.fail2ban = lib.mkIf cfg.recommendedDefaults {
    maxretry = 5;
    bantime = "24h";
    bantime-increment = {
      enable = true;
      formula = "ban.Time * math.exp(float(ban.Count+1)*banFactor)/math.exp(1*banFactor)";
      maxtime = "168h";
      overalljails = true;
    };
  };
}
