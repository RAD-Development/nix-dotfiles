{ config, lib, ... }:
{
  config = {
    services = {
      endlessh-go = lib.mkIf (!builtins.elem 22 config.services.openssh.ports) {
        enable = true;
        port = 22;
      };
    };

    networking.firewall = lib.mkIf config.services.openssh.enable {
      allowedTCPPorts = config.services.openssh.ports ++ [ 22 ];
    };
  };
}
