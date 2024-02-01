# BIASED
{ config, lib, ... }: {
  config = {
    services = {

      openssh = lib.mkIf config.services.gitea.enable {
        extraConfig = ''
          Match User gitea
            PermitTTY no
            X11Forwarding no
        '';
      };

      gitea.settings."ssh.minimum_key_sizes" = lib.mkIf config.services.gitea.enable {
        ECDSA = -1;
        RSA = 4095;
      };

      endlessh-go = lib.mkIf (!builtins.elem 22 config.services.openssh.ports) {
        enable = true;
        port = 22;
      };
    };

    networking.firewall = lib.mkIf config.services.openssh.enable { allowedTCPPorts = config.services.openssh.ports ++ [ 22 ]; };
  };
}
