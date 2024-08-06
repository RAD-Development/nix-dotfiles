{
  config,
  lib,
  pkgs,
  ...
}:

{

  networking = {
    hostId = "dc2f9781";
    firewall.enable = false;
  };

  systemd.network = {
    enable = true;
    networks = {
      # enable DHCP for primary ethernet adapter
      "10-lan" = {
        matchConfig.Name = "eno1";
        address = [ "192.168.76.2/24" ];
        routes = [ { routeConfig.Gateway = "192.168.76.1"; } ];
        IPForward = "yes";
        linkConfig.RequiredForOnline = "routable";
      };
      # default lan settings
      "60-def-lan" = {
        matchConfig.type = "ether";
        DHCP = "ipv4";
        IPForward = "yes";
        #routes = [ { routeConfig.Gateway = "192.168.76.1"; } ];
        linkConfig.RequiredForOnline = "no";
      };
    };
  };
}
