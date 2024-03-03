{
  pkgs,
  lib,
  config,
  name,
  ...
}:
import ../default.nix {
  inherit
    pkgs
    lib
    config
    name
    ;
  publicKeys = [
    # photon
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOGcqhLaKsjwAnb6plDavAhEyQHNvFS9Uh5lMTuwMhGF alice@parthenon-7588"
    # gh
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGoaEmzaS9vANckvBmqrYSHdFR0sPL4Xgeonbh9KcgFe gitlab keypair"
    # janus
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAfcO9p5opG8Tym6tcLkat6YGCcE6vwg0+V4MTC5WKop alice@parthenon-7588"
    # palatine
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP59pDsx34k2ikrKa0eVacj0APSGivaij3lP9L0Zd9au alice@parthenon-7588"
  ];
}
