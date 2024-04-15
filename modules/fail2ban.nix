{ config, lib, ... }:
{
  services.fail2ban = {
    enable = lib.mkIf config.networking.firewall.enable (lib.mkDefault true);
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
