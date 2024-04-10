{ config, lib, ... }:
{
  config = {
    services = {
      endlessh-go = lib.mkIf (!builtins.elem 22 config.services.openssh.ports) {
        enable = lib.mkDefault true;
        port = 22;
      };
    };

    networking.firewall = lib.mkIf config.services.endlessh-go.enable { allowedTCPPorts = [ 22 ]; };
  };
}
