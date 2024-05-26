{ lib, ... }:
{
  system.activationScripts.setZerotierName = lib.stringAfter [ "var" ] ''
    echo "ebe7fbd44565ba9d=ztkubnet" > /var/lib/zerotier-one/devicemap 
  '';

  services.zerotierone = {
    enable = true;
    joinNetworks = [ "ebe7fbd44565ba9d" ];
  };
  systemd.network = {
    enable = true;
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
        matchConfig.Name = "ztkubnet";
        networkConfig.Bridge = "brkubnet";
        linkConfig.RequiredForOnline = "enslaved";
      };
      "40-brkubnet" = {
        matchConfig.Name = "brkubnet";
        bridgeConfig = { };
        linkConfig.RequiredForOnline = "no";
      };
    };
  };
}
