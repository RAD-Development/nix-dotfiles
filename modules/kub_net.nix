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
    vlans = {
      vlan100 = {
        id = 100;
        interface = "ztkubnet";
      };
    };
    interfaces.vlan100.ipv4.addresses = [
      {
        address = "10.10.10.3";
        prefixLength = 24;
      }
    ];
  };
}
