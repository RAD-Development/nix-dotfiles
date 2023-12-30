# BIASED
{ config, lib, ... }:
{
  config = {
    services = lib.mkIf config.services.gitea.enable {
      fail2ban = {
        enable = true;
        
      };

      openssh = {
        extraConfig = ''
          Match User gitea
            AllowAgentForwarding no
            AllowTcpForwarding no
            PermitTTY no
            X11Forwarding no
        '';
      };

      gitea.settings."ssh.minimum_key_sizes" = {
        ECDSA = -1;
        RSA = 4095;
      };
    };
  };
}