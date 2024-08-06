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
        routes = [ { Gateway = "192.168.76.1"; } ];
        networkConfig = {
          IPv4Forwarding = true;
          IPv6Forwarding = true;
        };
        linkConfig.RequiredForOnline = "routable";
      };
      # default lan settings
      "60-def-lan" = {
        matchConfig.type = "ether";
        networkConfig = {
          DHCP = "ipv4";
          IPv4Forwarding = true;
          IPv6Forwarding = true;
        };
        #routes = [ { routeConfig.Gateway = "192.168.76.1"; } ];
        linkConfig.RequiredForOnline = "no";
      };
    };
  };
}
