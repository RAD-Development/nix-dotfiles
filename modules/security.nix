# BIASED
{ config, lib, ... }:
{
  config = {
    services = lib.mkIf config.services.gitea.enable {
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

    networking.firewall = lib.mkIf config.services.openssh.enable {
      allowedTCPPorts = config.services.openssh.ports;
    };
  };
}
