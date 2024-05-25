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
        address = "192.168.69.0";
        prefixLength = 24;
      }
    ];
  };
}
