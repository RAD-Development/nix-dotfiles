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
      # "10-lan" = {
      #   matchConfig.Name = "eno1";
      #   address = [ "192.168.76.2/32" ];
      #   routes = [ { routeConfig.Gateway = "192.168.76.1"; } ];
      #   linkConfig.RequiredForOnline = "routable";
      # };
      # default lan settings
      "60-def-lan" = {
        matchConfig.Name = "eno*";
        networkConfig.DHCP = "ipv4";
        routes = [ { routeConfig.Gateway = "192.168.76.1"; } ];
        linkConfig.RequiredForOnline = "no";
      };
    };
  };
}
