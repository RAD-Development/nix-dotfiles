{ inputs, ... }:
{
  users = [
    "alice"
    "richie"
  ];
  modules = [
    inputs.attic.nixosModules.atticd
    inputs.microvm.nixosModules.host
  ];
}
