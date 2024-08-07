{
  config,
  lib,
  pkgs,
  ...
}:

{
  services.k3s = {
    enable = true;
    extraFlags = "--cluster-cidr 192.168.69.0/24";
    # tokenFile = #TODO: set this up after building the first node lol
    # serverAddr =
  };
}
