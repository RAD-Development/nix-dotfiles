{ inputs, src, ... }:
{
  users = [
    "alice"
    "richie"
  ];
  modules = [
    inputs.attic.nixosModules.atticd
    (src + "/modules/opt/microvm-host.nix")
  ];
}
