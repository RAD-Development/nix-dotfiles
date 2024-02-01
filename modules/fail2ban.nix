{ config, lib, libS, ... }:

let cfg = config.services.fail2ban;
in {
  options = { services.fail2ban = { recommendedDefaults = libS.mkOpinionatedOption "use fail2ban with recommended defaults"; }; };

  config.services.fail2ban = lib.mkIf cfg.recommendedDefaults {
    maxretry = 5;
    bantime = "24h";
    bantime-increment = {
      enable = true;
      formula = "ban.Time * math.exp(float(ban.Count+1)*banFactor)/math.exp(1*banFactor)";
      maxtime = "168h";
      overalljails = true;
    };

    jails = {
      apache-nohome-iptables.settings = {
        # Block an IP address if it accesses a non-existent
        # home directory more than 5 times in 10 minutes,
        # since that indicates that it's scanning.
        filter = "apache-nohome";
        action = ''iptables-multiport[name=HTTP, port="http,https"]'';
        logpath = "/var/log/httpd/error_log*";
        backend = "systemd";
        findtime = 600;
        bantime = 600;
        maxretry = 5;
      };

      dovecot = {
        settings = {
          filter = "dovecot[mode=aggressive]";
          maxretry = 3;
        };
      };
    };
  };
}
