{ lib, ... }:
{
  system.activationScripts.setZerotierName = lib.stringAfter [ "var" ] ''
    echo "ebe7fbd44565ba9d=ztkubnet" > /var/lib/zerotier-one/devicemap 
  '';

  services.zerotierone = {
    enable = true;
    joinNetworks = [ "ebe7fbd44565ba9d" ];
  };

  networking = {
    bridges.brkubnet.interfaces = [ "ztkubnet" ];
    interfaces.brkubnet.ipv4.addresses = [
      {
        address = "192.168.192.2";
        prefixLength = 24;
      }
    ];

    vlans.vlan100 = {
      id = 100;
      interface = "brkubnet";
    };
    interfaces.vlan100.ipv4.addresses = [
      {
        address = "10.10.10.4";
        prefixLength = 24;
      }
    ];
  };
}
