{ lib, config, ... }:
let
  cfg = config.services.rad-dev.k3s-net;
in
{
  options = {
    services.rad-dev.k3s-net = {
      enable = lib.mkOption {
        default = true;
        example = true;
        description = "Whether to enable k3s-net.";
        type = lib.types.bool;
      };
    };
  };

  config = lib.mkIf cfg.enable {

    system.activationScripts.setZerotierName = lib.stringAfter [ "var" ] ''
      echo "ebe7fbd44565ba9d=ztkubnet" > /var/lib/zerotier-one/devicemap 
    '';

    services.zerotierone = {
      enable = lib.mkDefault true;
      joinNetworks = [ "ebe7fbd44565ba9d" ];
    };

    systemd.network = {
      enable = lib.mkDefault true;
      wait-online.anyInterface = true;
      netdevs = {
        "20-brkubnet" = {
          netdevConfig = {
            Kind = "bridge";
            Name = "brkubnet";
          };
        };
      };
      networks = {
        "30-ztkubnet" = {
          matchConfig.Name = [ "ztkubnet" ];
          networkConfig.Bridge = "brkubnet";
          linkConfig.RequiredForOnline = "enslaved";
        };
        "40-brkubnet" = {
          matchConfig.Name = "brkubnet";
          bridgeConfig = { };
          networkConfig.LinkLocalAddressing = "no";
          linkConfig.RequiredForOnline = "no";
        };
        "41-vms" = {
          matchConfig.Name = [ "vm-*" ];
          networkConfig.Bridge = "brkubnet";
          linkConfig.RequiredForOnline = "enslaved";
        };
        "42-kubnet-accuse" = {
          matchConfig.Name = "kubnet-accuse";
          networkConfig.Bridge = "brkubnet";
          linkConfig.RequiredForOnline = "enslaved";
          address = [ "192.168.69.20/24" ];
        };
      };
    };

    # enable experimental networkd backend so networking doesnt break on hybrid systems
    networking.useNetworkd = lib.mkDefault true;
  };
}
